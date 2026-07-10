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

Mouse support is **on**: click to select panes/windows, drag borders to
resize, scroll to enter copy mode.

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
