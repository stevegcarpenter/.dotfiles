#!/usr/bin/env python3
"""Run with python3 -B -m unittest discover -s tmux/tests -v."""
import importlib.util
import json
import os
from pathlib import Path
import tempfile
import unittest
from unittest.mock import patch

SPEC = importlib.util.spec_from_file_location(
    "agent_status", Path(__file__).resolve().parents[1] / "custom_modules/scripts/agent_status.py")
agent = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(agent)


def event(name, **kwargs):
    return dict(hook_event_name=name, **kwargs)


class StateTests(unittest.TestCase):
    def test_finished_persists_until_new_prompt(self):
        state = agent.transition({}, event("UserPromptSubmit"))
        state = agent.transition(state, event("Stop"))
        for _ in range(100):
            state = agent.transition(state, event("Notification", notification_type="idle_prompt"))
            self.assertEqual(agent.effective(state), "finished")
        self.assertEqual(agent.transition(state, event("UserPromptSubmit"))["status"], "working")

    def test_questions_survive_other_parallel_tool_completions(self):
        state = agent.transition({}, event("PreToolUse", tool_name="AskUserQuestion", tool_use_id="q"))
        state = agent.transition(state, event("PostToolUse", tool_name="Bash", tool_use_id="b"))
        self.assertEqual(agent.effective(state), "question")
        state = agent.transition(state, event("PostToolUse", tool_name="AskUserQuestion", tool_use_id="q"))
        self.assertEqual(agent.effective(state), "working")

    def test_async_question_is_not_answered_by_tool_return(self):
        state = agent.transition({}, event("PreToolUse", tool_name="request_user_input_async", tool_use_id="q"))
        state = agent.transition(state, event("PostToolUse", tool_name="request_user_input_async", tool_use_id="q"))
        self.assertEqual(agent.effective(state), "question")

    def test_permission_without_tool_id_and_notification(self):
        state = agent.transition({}, event("PermissionRequest", tool_name="Bash"))
        state = agent.transition(state, event("Notification", notification_type="permission_prompt"))
        state = agent.transition(state, event("PostToolUse", tool_name="Bash", tool_use_id="b"))
        self.assertEqual(agent.effective(state), "working")

    def test_tool_failure_is_not_turn_failure(self):
        state = agent.transition({}, event("PostToolUseFailure"))
        self.assertEqual(agent.effective(state), "working")
        state = agent.transition(state, event("StopFailure"))
        self.assertEqual(agent.effective(state), "failed")

    def test_compaction_does_not_become_idle(self):
        for name, extra in (("PreCompact", {}), ("PostCompact", {}),
                            ("SessionStart", {"source": "compact"})):
            self.assertEqual(agent.effective(agent.transition({}, event(name, **extra))), "working")

    def test_interrupt_and_exit_clear_attention(self):
        state = agent.transition({}, event("PermissionRequest"))
        self.assertEqual(agent.effective(agent.transition(state, event("Interrupt"))), "idle")
        self.assertEqual(agent.indicator([agent.effective(agent.transition(state, event("SessionEnd")))], 0), "")

    def test_background_child_keeps_window_working(self):
        state = agent.transition({}, event("SubagentStart", agent_id="child"))
        state = agent.transition(state, event("Stop"))
        self.assertEqual(agent.effective(state), "working")
        state = agent.transition(state, event("SubagentStop", agent_id="child"))
        self.assertEqual(agent.effective(state), "finished")

    def test_window_priority_and_animation(self):
        self.assertIn("?", agent.indicator(list(agent.PRIORITY), 0))
        self.assertIn("!", agent.indicator(["failed", "working", "finished"], 0))
        self.assertNotEqual(agent.indicator(["working"], 0), agent.indicator(["working"], 2))
        self.assertEqual(agent.indicator(["finished"], 0), agent.indicator(["finished"], 2))
        self.assertEqual(agent.indicator([], 0), "")

    def test_terminal_fallback_does_not_classify_prose_or_running_tool_errors(self):
        self.assertIsNone(agent.terminal_stop("Tests failed: Error\n› ", "codex"))
        self.assertIsNone(agent.terminal_stop("\x1b[31m■ Error\nWorking (esc to interrupt)\n› ", "codex"))
        self.assertEqual(agent.terminal_stop("\x1b[31m■ Rate limit exceeded\x1b[0m\n› ", "codex"), "failed")
        self.assertEqual(agent.terminal_stop("■ Conversation interrupted - tell the model what to do\n› ", "codex"), "idle")
        self.assertEqual(agent.terminal_stop("⎿ Interrupted · What should Claude do instead?\n❯", "claude"), "idle")

    def test_installer_preserves_settings_and_is_idempotent(self):
        with tempfile.TemporaryDirectory() as tmp:
            home = Path(tmp)
            path = home / ".claude/settings.json"
            path.parent.mkdir()
            original = {"permissions": {"allow": ["Read"]}, "hooks": {
                "Stop": [{"hooks": [{"type": "command", "command": "echo existing"}]}]}}
            path.write_text(json.dumps(original))
            agent.install(home)
            first = path.read_text()
            agent.install(home)
            self.assertEqual(first, path.read_text())
            data = json.loads(first)
            self.assertEqual(data["permissions"], original["permissions"])
            self.assertEqual(len(data["hooks"]["Stop"]), 2)
            self.assertEqual(len(list(path.parent.glob("*.before-tmux-agents-*"))), 1)

    def test_topology_removes_dead_and_reused_pids_and_tracks_moved_panes(self):
        monitor = object.__new__(agent.Monitor)
        monitor.states = {
            "10:old": dict(pid=10, birth="old", pane="%1", status="finished"),
            "20:birth": dict(pid=20, birth="birth", pane="%2", status="working"),
            "30:birth": dict(pid=30, birth="birth", pane="%3", status="finished"),
        }
        monitor.tmux = lambda *args: "%1 @1 1\n%4 @2 4"
        procs = {1: (0, "shell", "zsh"), 4: (0, "shell", "zsh"),
                 10: (1, "new", "claude"), 30: (4, "birth", "codex")}
        with patch.object(agent, "processes", return_value=procs):
            monitor.topology()
        self.assertNotIn("10:old", monitor.states)
        self.assertNotIn("20:birth", monitor.states)
        self.assertEqual(monitor.states["30:birth"]["pane"], "%4")
        self.assertEqual(monitor.states["30:birth"]["status"], "finished")


if __name__ == "__main__":
    unittest.main()
