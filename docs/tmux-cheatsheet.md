# tmux Cheat Sheet

> **Prefix is `Ctrl-q`** (custom, not the default `Ctrl-b`).
> All bindings below are `prefix + key` unless marked otherwise.
> `prefix q` sends a literal prefix through (useful for nested tmux).

## Custom bindings (from `.tmux.conf`)

| Key | Action |
|-----|--------|
| `r` | Reload `~/.tmux.conf` (shows "Reloaded!") |
| `\|` | Split pane horizontally (side by side) |
| `-` | Split pane vertically (stacked) |
| `h` / `j` / `k` / `l` | Move to pane left / down / up / right |
| `Ctrl-h` / `Ctrl-l` | Resize pane left / right (4 cells) |
| `Ctrl-j` / `Ctrl-k` | Resize pane down / up (2 cells) |
| `y` | Toggle synchronize-panes (type into all panes at once) |
| `Ctrl-c` | Copy the current pane's full path to the macOS clipboard; the status line shows "Path copied!" and the folder pill flashes "Copied!". Clicking that pill does the same |
| `?` | Float `~/.dotfiles/docs` in nvim over the current pane (these cheat sheets); `:q` returns to whatever the pane was doing. Shadows the default `list-keys`, still available as `list-keys` from `prefix + :` |

Mouse support is **on**: click to select panes/windows, drag borders to
resize, scroll to enter copy mode. Clicking the folder pill on the right of
the status bar copies the current pane's full path (same as `prefix Ctrl-c`).

## Agent indicators

Window pills combine the states of local Codex and Claude Code processes in
**all** their panes, including panes that aren't focused.

| Indicator | Meaning |
|-----------|---------|
| No indicator | No agent present |
| Grey `●` | Idle or interrupted |
| Pulsing green `●` | Working, including compaction and tracked background subagents |
| Green `✓` | Finished; stays green until another task starts or the agent exits |
| Orange `?` | Needs an answer, permission, or plan approval |
| Red `!` | Turn failed and stopped; individual recoverable tool errors don't count |

When several agents share a window, priority is **question > failure > working
> finished > idle**. Moving a pane updates its destination window. Process
cleanup runs every three seconds; state changes normally appear within half a
second. The working dot cycles through four brightness steps over two seconds.

### Setup on a new machine

After installing tmux, Python 3, Codex, and Claude Code, run:

```sh
python3 ~/.dotfiles/tmux/custom_modules/scripts/agent_status.py install --reload
```

This merges the status hooks into `~/.claude/settings.json` and
`~/.codex/hooks.json`, preserving other settings/hooks and saving timestamped
backups beside changed files. It is safe to run again. Restart existing agents
to load their hooks; in Codex, use **`/hooks` to review and trust the new hooks**.
The integration does not bypass Codex's hook trust or change tool permissions.

Already-running agents without hooks initially show grey; their previous
completion state cannot be reconstructed from lifecycle events they didn't
report. Desktop agents and remote SSH agents are not associated with local
tmux panes.

The monitor starts from `.tmux.conf`, with a lock preventing duplicate monitors
on reload. It stores only lifecycle metadata under
`/tmp/tmux-agent-status-<uid>/`, never prompts, responses, or tool arguments.
Completion survives monitor restarts. Neither completion nor long periods of
silence cause an automatic change to idle.

### API limitations

Claude reports terminal API failures through `StopFailure`; Codex currently
doesn't expose that hook. The monitor therefore also recognizes Codex's red
terminal error marker and the agents' explicit interruption messages near the
bottom of a working pane. This fallback depends on terminal UI versions and
can miss a marker that has scrolled away. It never infers failure from ordinary
text mentioning errors. Hooks remain the primary source of state.

An approval indicator can remain orange while an approved tool executes,
until its result hook arrives: neither integration has a general hook for the
instant every approval dialog is dismissed. Asynchronous Codex questions stay
orange until the next submitted prompt or completion. Questions written as
ordinary conversational prose are completion, not a structured input request.

Validation:

```sh
python3 -B -m unittest discover -s tmux/tests -v
python3 -B tmux/tests/integration_agent_status.py
```

The integration test uses a separate tmux server and synthetic agent events;
it doesn't send prompts to either model or alter existing sessions.

## Copy mode (vi keys)

| Key | Action |
|-----|--------|
| `[` | Enter copy mode |
| `v` | Begin selection *(custom)* |
| `r` | Toggle rectangle/block selection *(custom)* |
| `y` | Copy selection to macOS clipboard via `pbcopy` and exit *(custom)* |
| `]` | Paste most recent tmux buffer |
| `q` | Exit copy mode |
| `/` `?` `n` `N` | Search forward / backward / next / previous |

## Panes (built-in)

| Key | Action |
|-----|--------|
| `z` | Zoom pane (toggle fullscreen) |
| `x` | Kill current pane (confirms) |
| `!` | Break pane out into its own new window |
| `{` / `}` | Swap pane with previous / next pane |
| `Ctrl-o` | Rotate all panes in window |
| `Space` | Cycle through pane layouts |
| `;` | Jump to last active pane |
| `Q` then number | Show pane numbers; press one to jump (`q` shows briefly) |

Move a pane into another window (command prompt, `prefix :`):

```
join-pane -t :2        # move current pane into window 2
join-pane -s :3        # pull window 3 in as a pane here
```

## Windows (built-in)

| Key | Action |
|-----|--------|
| `c` | Create new window |
| `,` | Rename window (auto-rename is off, so names stick) |
| `n` / `p` | Next / previous window |
| `0`–`9` | Jump to window by number |
| `w` | Interactive window/session picker |
| `&` | Kill current window (confirms) |
| `.` | Move window to a new index (prompts) |

## Sessions (built-in)

| Key | Action |
|-----|--------|
| `d` | Detach from session |
| `s` | List/switch sessions |
| `$` | Rename session |
| `(` / `)` | Previous / next session |

From the shell: `tmux ls`, `tmux attach -t <name>`, `tmux new -s <name>`,
`tmux kill-session -t <name>`.

## Plugins

| Key | Action |
|-----|--------|
| `I` | tpm: install plugins listed in `.tmux.conf` |
| `U` | tpm: update plugins |
| `Alt-u` | tpm: remove plugins no longer listed |
| `Ctrl-s` | tmux-resurrect: save session layout |
| `Ctrl-r` | tmux-resurrect: restore saved session |
| `F` | tmux-fzf: fuzzy-find sessions/windows/panes/commands |

tmux-continuum auto-saves periodically and auto-restores on tmux start
(`@continuum-restore` is on), so `Ctrl-s`/`Ctrl-r` are rarely needed manually.

## Notes

- **vim-tmux-navigator**: inside nvim, bare `Ctrl-h/j/k/l` (no prefix) moves
  between vim splits and crosses into adjacent tmux panes. The tmux side of
  the plugin isn't configured in `.tmux.conf`, so from a non-vim pane use
  `prefix h/j/k/l` to move back.
- Pane borders show the pane's current directory at the top.
- Command prompt (`prefix :`) uses emacs keys (`Ctrl-a`/`Ctrl-e`, etc.).
