#!/usr/bin/env python3
"""Exercise actual tmux formats/monitor with synthetic hook metadata, isolated server."""
import importlib.util
import json
import os
from pathlib import Path
import subprocess
import shlex
import sys
import tempfile
import time

ROOT = Path(__file__).resolve().parents[2]
SCRIPT = ROOT / "tmux/custom_modules/scripts/agent_status.py"
spec = importlib.util.spec_from_file_location("agent_status", SCRIPT)
agent = importlib.util.module_from_spec(spec)
spec.loader.exec_module(agent)
label = "agent-status-test-%s" % os.getpid()


def tmux(*args):
    return subprocess.check_output(["tmux", "-L", label, *args], text=True).strip()


def wait_for(check):
    deadline = time.monotonic() + 6
    while time.monotonic() < deadline:
        if check():
            return
        time.sleep(0.1)
    raise AssertionError("Timed out waiting for indicator")


monitor = None
try:
    tmux("-f", "/dev/null", "new-session", "-d", "-s", "test", "-x", "120", "-y", "30", "/bin/sh")
    socket, server_pid = tmux("display-message", "-p", "#{socket_path} #{pid}").split()
    pane = tmux("display-message", "-p", "#{pane_id}")
    config = (ROOT / "tmux/.tmux.conf").read_text()
    # Avoid restoring the user's sessions/plugins into the isolated test server.
    config = "\n".join(line for line in config.splitlines()
                       if "tpm/tpm" not in line and "agent_status.py\" daemon" not in line)
    with tempfile.NamedTemporaryFile(mode="w", suffix=".conf") as f:
        f.write(config)
        f.flush()
        tmux("source-file", f.name)
    monitor = subprocess.Popen([sys.executable, "-B", str(SCRIPT), "daemon", socket, server_pid])
    _, db = agent.database(socket, server_pid)

    def emit(name, target=pane, **fields):
        pid = int(tmux("display-message", "-p", "-t", target, "#{pane_pid}"))
        data = dict(hook_event_name=name, pid=pid, birth=agent.processes()[pid][1],
                    pane=target, provider="claude", observed=time.time(), **fields)
        with db:
            db.execute("INSERT INTO events(body) VALUES (?)", (json.dumps(data),))

    def value(target=pane):
        return tmux("show-option", "-wqv", "-t", target, "@agent_indicator")

    emit("SessionStart")
    wait_for(lambda: "overlay_0" in value())
    emit("UserPromptSubmit")
    wait_for(lambda: "●" in value() and "overlay_0" not in value())
    first = value()
    wait_for(lambda: value() != first)
    emit("Stop")
    wait_for(lambda: "✓" in value())
    formatted = tmux("display-message", "-p", "-t", pane, "#{E:window-status-current-format}")
    assert "✓" in formatted and "#{" not in formatted, formatted
    assert "#[fg=#a6e3a1]✓#[fg=#cdd6f4]" in formatted, formatted
    duplicate = subprocess.run([sys.executable, "-B", str(SCRIPT), "daemon", socket, server_pid], timeout=3)
    assert duplicate.returncode == 0
    monitor.terminate()
    monitor.wait(timeout=3)
    monitor = subprocess.Popen([sys.executable, "-B", str(SCRIPT), "daemon", socket, server_pid])
    time.sleep(1)
    assert "✓" in value(), "Finished state was lost on restart"

    second = tmux("split-window", "-d", "-P", "-F", "#{pane_id}", "-t", pane, "/bin/sh")
    emit("UserPromptSubmit", target=second)
    emit("PermissionRequest", target=second, tool_name="Bash")
    wait_for(lambda: "?" in value())
    emit("PostToolUse", target=second, tool_name="Bash", tool_use_id="tool1")
    wait_for(lambda: "●" in value())
    emit("StopFailure", target=second)
    wait_for(lambda: "!" in value())
    other = tmux("new-window", "-d", "-P", "-F", "#{pane_id}", "-n", "other", "/bin/sh")
    tmux("move-pane", "-d", "-s", second, "-t", other)
    wait_for(lambda: "✓" in value() and "!" in value(other))
    inactive = tmux("display-message", "-p", "-t", pane, "#{E:window-status-format}")
    assert "✓" in inactive and "#{" not in inactive, inactive
    tmux("kill-pane", "-t", second)
    wait_for(lambda: value(other) == "")
    emit("Notification", notification_type="idle_prompt")
    time.sleep(1)
    assert "✓" in value(), "Idle notification overwrote completion"
    emit("SessionEnd")
    wait_for(lambda: value() == "")
    # Exercise the actual hook entry point, including TMUX inheritance, process
    # ancestry and queue transport, without making any model/API requests.
    with tempfile.TemporaryDirectory() as tmp:
        fixture = Path(tmp) / "claude"
        source = Path(tmp) / "fixture.c"
        source.write_text('#include <stdlib.h>\n#include <unistd.h>\n'
                          'int main(int argc, char **argv) {\n'
                          '  if (argc != 2 || system(argv[1]) != 0) return 1;\n'
                          '  sleep(60); return 0;\n}\n')
        subprocess.run(["cc", str(source), "-o", str(fixture)], check=True)
        payload = Path(tmp) / "event.json"
        payload.write_text(json.dumps(dict(hook_event_name="Stop", session_id="fixture")))
        shell_code = "%s %s hook claude < %s" % tuple(
            shlex.quote(str(p)) for p in (sys.executable, SCRIPT, payload))
        command = "%s %s" % (shlex.quote(str(fixture)), shlex.quote(shell_code))
        tmux("set-option", "-g", "remain-on-exit", "on")
        actual = tmux("new-window", "-d", "-P", "-F", "#{pane_id}", "-n", "actual-hook", command)
        try:
            wait_for(lambda: "✓" in value(actual))
        except AssertionError:
            print(tmux("capture-pane", "-p", "-t", actual), flush=True)
            pid = int(tmux("display-message", "-p", "-t", actual, "#{pane_pid}"))
            procs = agent.processes()
            print("Fixture processes:", {p: v for p, v in procs.items()
                  if pid in set(agent.ancestors(p, procs))}, flush=True)
            print("State:", db.execute("SELECT * FROM state").fetchall(), flush=True)
            raise
        tmux("kill-window", "-t", actual)
    print("PASS: actual hook transport, real tmux formats, animation, sticky completion, restart, singleton, multiple panes, priorities, moving panes, exit cleanup")
finally:
    if monitor:
        monitor.terminate()
        monitor.wait(timeout=3)
    subprocess.run(["tmux", "-L", label, "kill-server"], stderr=subprocess.DEVNULL)
