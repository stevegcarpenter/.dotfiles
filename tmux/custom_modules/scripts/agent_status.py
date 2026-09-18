#!/usr/bin/env python3
"""Local agent lifecycle hooks and one lightweight monitor per tmux server.

Hooks enqueue metadata only (never prompts, tool arguments, or responses). The
monitor aggregates every pane, persists completion, and animates cached window
options. No subprocess is launched by the window-status format itself.
"""

import argparse
import fcntl
import hashlib
import json
import os
from pathlib import Path
import re
import sqlite3
import subprocess
import sys
import time


SCRIPT = Path(__file__).resolve()
PRIORITY = {"idle": 0, "finished": 1, "working": 2, "failed": 3, "question": 4}
QUESTIONS = {"AskUserQuestion", "ExitPlanMode", "request_user_input",
             "request_user_input_async", "functions.request_user_input",
             "functions.request_user_input_async"}
COMMON_EVENTS = ("SessionStart", "SessionEnd", "UserPromptSubmit", "PreToolUse",
                 "PostToolUse", "PermissionRequest", "PreCompact", "PostCompact",
                 "Stop", "SubagentStart", "SubagentStop")
EVENTS = {
    "codex": COMMON_EVENTS + ("Interrupt",),
    "claude": COMMON_EVENTS + ("StopFailure", "PostToolUseFailure", "Notification",
                               "Elicitation", "ElicitationResult"),
}


def run(args):
    return subprocess.check_output(args, text=True, stderr=subprocess.DEVNULL,
                                   timeout=3).strip()


def processes():
    result = {}
    # lstart protects against PID reuse. comm deliberately excludes arguments.
    for line in run(["ps", "-axo", "pid=,ppid=,lstart=,comm="]).splitlines():
        parts = line.split(None, 7)
        if len(parts) == 8:
            result[int(parts[0])] = (int(parts[1]), " ".join(parts[2:7]), parts[7])
    return result


def ancestors(pid, procs):
    seen = set()
    while pid in procs and pid not in seen:
        seen.add(pid)
        yield pid
        pid = procs[pid][0]


def provider(command):
    name = Path(command).name
    return name if name in ("codex", "claude") else None


def database(socket, server_pid):
    identity = hashlib.sha256((socket + ":" + server_pid).encode()).hexdigest()[:20]
    directory = Path("/tmp") / ("tmux-agent-status-%s" % os.getuid()) / identity
    directory.mkdir(mode=0o700, parents=True, exist_ok=True)
    os.chmod(directory.parent, 0o700)
    os.chmod(directory, 0o700)
    db = sqlite3.connect(str(directory / "state.sqlite3"), timeout=1)
    db.execute("CREATE TABLE IF NOT EXISTS events (id INTEGER PRIMARY KEY, body TEXT)")
    db.execute("CREATE TABLE IF NOT EXISTS state (id TEXT PRIMARY KEY, body TEXT)")
    db.commit()
    return directory, db


def hook(source):
    if not os.environ.get("TMUX") or not os.environ.get("TMUX_PANE"):
        return
    event = json.load(sys.stdin)
    socket, server_pid, _ = os.environ["TMUX"].rsplit(",", 2)
    procs = processes()
    owner = next((pid for pid in ancestors(os.getppid(), procs)
                  if provider(procs[pid][2]) == source), None)
    if owner is None:
        return  # Desktop/remote daemon hooks must not claim an unrelated pane.
    # Only metadata used to determine state crosses into the local queue.
    fields = ("hook_event_name", "session_id", "source", "tool_name", "tool_use_id",
              "agent_id", "notification_type", "is_interrupt")
    data = {key: event[key] for key in fields if key in event}
    data.update(pane=os.environ["TMUX_PANE"], pid=owner, birth=procs[owner][1],
                provider=source, observed=time.time())
    _, db = database(socket, server_pid)
    with db:
        db.execute("INSERT INTO events(body) VALUES (?)", (json.dumps(data),))
    db.close()


def transition(state, event):
    """Reduce lifecycle events without treating an individual tool error as failure."""
    state = dict(state)
    waiting = dict(state.get("waiting", {}))
    children = set(state.get("children", []))
    name = event["hook_event_name"]
    tool = event.get("tool_name", "")
    token = event.get("tool_use_id") or tool or "input"
    status = state.get("status", "idle")
    if name == "SessionStart":
        if event.get("source") == "compact":
            status = "working"
        else:
            status, waiting, children = "idle", {}, set()
    elif name == "SessionEnd":
        status, waiting, children = "gone", {}, set()
    elif name == "UserPromptSubmit":
        status, waiting = "working", {}
    elif name == "Interrupt" or event.get("is_interrupt"):
        status, waiting, children = "idle", {}, set()
    elif name == "StopFailure":
        status, waiting, children = "failed", {}, set()
    elif name == "Stop":
        status, waiting = "finished", {}
    elif name == "SubagentStart":
        children.add(event.get("agent_id", "subagent"))
    elif name == "SubagentStop":
        children.discard(event.get("agent_id", "subagent"))
    elif name in ("PermissionRequest", "Elicitation"):
        waiting[token] = tool
    elif name == "Notification":
        if event.get("notification_type") in (
                "permission_prompt", "elicitation_dialog", "elicitation_url_dialog"):
            # A delayed notification repeats an existing wait, not a second one.
            if not waiting:
                waiting["notification"] = ""
        # idle_prompt follows completion; it must NEVER replace the checkmark.
    elif name in ("PreToolUse", "PostToolUse", "PostToolUseFailure", "ElicitationResult"):
        if name == "PreToolUse" and tool in QUESTIONS:
            waiting[token] = tool
        elif name != "PreToolUse" and not tool.endswith("request_user_input_async"):
            waiting.pop(token, None)
            # PermissionRequest has no tool_use_id in Codex.
            waiting.pop(tool, None)
            waiting.pop("notification", None)
        status = "working"
    elif name in ("PreCompact", "PostCompact"):
        status = "working"
    state.update(status=status, waiting=waiting, children=sorted(children))
    return state


def effective(state):
    if state.get("waiting"):
        return "question"
    if state.get("children") and state["status"] in ("idle", "finished"):
        return "working"
    return state["status"]


def indicator(states, frame):
    states = [s for s in states if s in PRIORITY]
    if not states:
        return ""
    status = max(states, key=PRIORITY.get)
    color, glyph = {
        "idle": ("#{E:@thm_overlay_0}", "●"),
        "finished": ("#{E:@thm_green}", "✓"),
        "question": ("#{E:@thm_peach}", "?"),
        "failed": ("#{E:@thm_red}", "!"),
        "working": (("#68845b", "#88ac75", "#{E:@thm_green}", "#88ac75")[frame % 4], "●"),
    }[status]
    # Change foreground only, preserving selected/unselected pill backgrounds.
    return "#[fg=%s]%s#[fg=#{E:@thm_fg}] " % (color, glyph)


ANSI = re.compile(r"\x1b\[[0-?]*[ -/]*[@-~]")


def terminal_stop(text, source):
    """Conservative fallback for gaps in lifecycle APIs, not general text inference.

    Match only terminal-owned markers near the bottom, and never while the
    agent's interrupt hint says it is working. These markers are version-specific.
    """
    plain = ANSI.sub("", text)
    if re.search(r"esc to interrupt", plain, re.I):
        return None
    if source == "codex":
        # Examine output before the composer, excluding its footer.
        output = re.split(r"(?m)^›", plain)[0]
        lines = [line.strip() for line in output.splitlines() if line.strip()][-6:]
        if any(line.startswith("■ Conversation interrupted") for line in lines):
            return "idle"
        # Codex renders terminal errors with a red square. Ordinary prose with
        # the word "error" (including failing test output) is not a signal.
        raw_output = re.split(r"(?m)^›", text)[0]
        raw_lines = [line for line in raw_output.splitlines() if ANSI.sub("", line).strip()][-6:]
        if any(re.search(r"\x1b\[(?:0;)?(?:31|91|38;5;(?:1|9|160|196))m[^\n]*■", line)
               for line in raw_lines):
            return "failed"
    else:
        if re.search(r"Interrupted\s*·\s*What should Claude do instead\?", plain):
            return "idle"
    return None


class Monitor:
    def __init__(self, socket, server_pid):
        self.socket, self.server_pid = socket, server_pid
        self.directory, self.db = database(socket, server_pid)
        self.states = dict((key, json.loads(body)) for key, body in
                           self.db.execute("SELECT id, body FROM state"))
        self.panes, self.procs, self.rendered = {}, {}, {}
        self.last_scan = 0
        self.saved = None

    def tmux(self, *args):
        return run(["tmux", "-S", self.socket, *args])

    def topology(self):
        rows = self.tmux("list-panes", "-a", "-F", "#{pane_id} #{window_id} #{pane_pid}")
        self.panes = {p: (w, int(pid)) for p, w, pid in (row.split() for row in rows.splitlines())}
        self.procs = processes()
        for pid, (_, birth, command) in self.procs.items():
            source = provider(command)
            if not source:
                continue
            lineage = set(ancestors(pid, self.procs))
            for pane, (_, pane_pid) in self.panes.items():
                if pane_pid in lineage:
                    key = str(pid) + ":" + birth
                    # Pane IDs can change when a process moves between panes.
                    if key in self.states:
                        self.states[key]["pane"] = pane
                    else:
                        self.states[key] = dict(pid=pid, birth=birth, pane=pane,
                                                provider=source, status="idle")
                    break
        self.states = {key: s for key, s in self.states.items()
                       if s["pane"] in self.panes and s["pid"] in self.procs
                       and self.procs[s["pid"]][1] == s["birth"]}

    def events(self):
        with self.db:
            rows = self.db.execute("SELECT id, body FROM events ORDER BY id").fetchall()
            for _, body in rows:
                event = json.loads(body)
                key = str(event["pid"]) + ":" + event["birth"]
                old = self.states.get(key, {})
                state = transition(old, event)
                state.update({k: event[k] for k in ("pid", "birth", "pane", "provider")})
                state["observed"] = event["observed"]
                # Never retain conversation content or transcript paths.
                self.states[key] = state
            if rows:
                self.db.execute("DELETE FROM events WHERE id <= ?", (rows[-1][0],))
            snapshot = json.dumps(self.states, sort_keys=True)
            if snapshot != self.saved:
                self.db.execute("DELETE FROM state")
                self.db.executemany("INSERT INTO state VALUES (?, ?)",
                                    [(key, json.dumps(s)) for key, s in self.states.items()])
                self.saved = snapshot

    def fallback(self):
        for state in self.states.values():
            if effective(state) not in ("working", "question"):
                continue
            try:
                text = self.tmux("capture-pane", "-p", "-e", "-t", state["pane"])
                # Only the terminal footer, never scrollback or the whole transcript.
                marker = terminal_stop("\n".join(text.splitlines()[-18:]), state["provider"])
                if marker:
                    state.update(status=marker, waiting={}, children=[])
            except subprocess.SubprocessError:
                pass  # A pane closing between scans is normal.

    def render(self, frame):
        windows = {window: [] for window, _ in self.panes.values()}
        for state in self.states.values():
            pane = self.panes.get(state["pane"])
            if pane:
                windows[pane[0]].append(effective(state))
        changed = False
        for window, states in windows.items():
            value = indicator(states, frame)
            if self.rendered.get(window) != value:
                self.tmux("set-option", "-w", "-t", window, "@agent_indicator", value)
                self.rendered[window] = value
                changed = True
        if changed:
            # Refresh all attached clients, including other sessions sharing a window.
            for client in self.tmux("list-clients", "-F", "#{client_name}").splitlines():
                self.tmux("refresh-client", "-S", "-t", client)

    def loop(self):
        with (self.directory / "monitor.lock").open("w") as lock:
            try:
                fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
            except BlockingIOError:
                return  # Config reloads must not spawn another animation loop.
            while True:
                now = time.monotonic()
                try:
                    if now - self.last_scan >= 3:
                        if self.tmux("display-message", "-p", "#{pid}") != self.server_pid:
                            return
                        self.topology()
                        self.fallback()
                        self.last_scan = now
                    self.events()
                    self.render(int(now * 2))
                except (subprocess.SubprocessError, OSError):
                    # Exit when the owning server disappears; never start a server.
                    if not Path(self.socket).exists():
                        return
                time.sleep(0.5)


def hook_config(source):
    command = 'python3 "%s" hook %s' % (SCRIPT, source)
    return {event: [{"hooks": [{"type": "command", "command": command, "timeout": 3}]}]
            for event in EVENTS[source]}


def install(home):
    """Merge only our hooks; keep unrelated settings and make a dated backup."""
    for source, path in (("claude", home / ".claude/settings.json"),
                         ("codex", home / ".codex/hooks.json")):
        data = json.loads(path.read_text()) if path.exists() else {}
        hooks = data.setdefault("hooks", {})
        # Idempotent updates also remove our handlers from obsolete event groups.
        for event, groups in list(hooks.items()):
            cleaned = []
            for group in groups:
                group = dict(group)
                group["hooks"] = [h for h in group.get("hooks", [])
                                  if str(SCRIPT) + '" hook ' not in h.get("command", "")]
                if group["hooks"]:
                    cleaned.append(group)
            hooks[event] = cleaned
        for event, groups in hook_config(source).items():
            hooks.setdefault(event, []).extend(groups)
        content = json.dumps(data, indent=2) + "\n"
        if path.exists() and path.read_text() == content:
            print("Already installed: %s" % path)
            continue
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            backup = path.with_name(path.name + ".before-tmux-agents-" + str(time.time_ns()))
            backup.write_bytes(path.read_bytes())
            os.chmod(backup, 0o600)
        temporary = path.with_name(path.name + ".tmux-agents.tmp")
        temporary.write_text(content)
        os.chmod(temporary, 0o600)
        temporary.replace(path)
        print("Installed: %s" % path)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    sub = parser.add_subparsers(dest="action", required=True)
    h = sub.add_parser("hook")
    h.add_argument("provider", choices=EVENTS)
    d = sub.add_parser("daemon")
    d.add_argument("socket")
    d.add_argument("server_pid")
    i = sub.add_parser("install")
    i.add_argument("--home", type=Path, default=Path.home())
    i.add_argument("--reload", action="store_true", help="also reload the default tmux server")
    args = parser.parse_args()
    if args.action == "hook":
        try:
            hook(args.provider)
        except (OSError, ValueError, KeyError, sqlite3.Error, subprocess.SubprocessError):
            pass  # Cosmetic hooks must never block or influence the agent.
        print("{}")
    elif args.action == "daemon":
        Monitor(args.socket, args.server_pid).loop()
    else:
        install(args.home)
        if args.reload:
            subprocess.run(["tmux", "source-file", str(args.home / ".tmux.conf")], check=True)
            print("Reloaded tmux. Restart agents; review Codex hooks with /hooks.")


if __name__ == "__main__":
    main()
