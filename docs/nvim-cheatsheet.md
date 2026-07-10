# Neovim Cheat Sheet (custom bindings only)

> **Leader is `Space`.** Only non-standard/custom bindings are listed —
> stock vim motions are omitted.

## General (`lua/core/keymaps.lua`)

| Key | Mode | Action |
|-----|------|--------|
| `Ctrl-n` | n | Clear search highlights |
| `x` | n | Delete char *without* yanking into register |
| `<leader>w` | n | Save file |
| `<leader>q` | n | Quit |
| `<leader>x` | n | Close current split window |

## Tabs

| Key | Action |
|-----|--------|
| `<leader>to` | Open new tab |
| `<leader>tx` | Close current tab |
| `<leader>tn` | Next tab |
| `<leader>tp` | Previous tab |

## Windows / splits

| Key | Action |
|-----|--------|
| `<leader>sm` | Toggle maximize current split (vim-maximizer) |
| `Ctrl-h/j/k/l` | Move between splits — and into tmux panes (vim-tmux-navigator) |

## File explorer & fuzzy finding

| Key | Action |
|-----|--------|
| `<leader>e` | Toggle nvim-tree file explorer |
| `<leader>ff` | Telescope: find files (respects .gitignore) |
| `<leader>fs` | Telescope: live grep (find string as you type) |
| `<leader>fc` | Telescope: grep string under cursor |
| `<leader>fb` | Telescope: list open buffers |
| `<leader>fh` | Telescope: help tags |

Inside a Telescope picker (insert mode):

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Ctrl-k` | Next / previous result |
| `Ctrl-q` | Send selected results to quickfix list and open it |

## Git (Telescope)

| Key | Action |
|-----|--------|
| `<leader>gc` | Git commits (Enter to checkout) |
| `<leader>gfc` | Git commits for current file |
| `<leader>gb` | Git branches (Enter to checkout) |
| `<leader>gs` | Git status with diff preview |

## LSP (active when a language server attaches)

| Key | Action |
|-----|--------|
| `gf` | Lspsaga finder: definition + references |
| `gd` | Peek definition (edit in floating window) |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `K` | Hover documentation |
| `<leader>ca` | Code actions |
| `<leader>rn` | Smart rename |
| `<leader>d` | Diagnostics under cursor |
| `<leader>D` | Diagnostics for line |
| `[d` / `]d` | Previous / next diagnostic in buffer |
| `<leader>o` | Toggle outline sidebar |
| `<leader>rs` | Restart LSP server |

TypeScript-only:

| Key | Action |
|-----|--------|
| `<leader>oi` | Organize imports |
| `<leader>ru` | Remove unused variables |
| `<leader>ai` | Add missing imports |

## Autocompletion (nvim-cmp, insert mode)

| Key | Action |
|-----|--------|
| `Ctrl-Space` | Trigger completion menu |
| `Ctrl-j` / `Ctrl-k` | Next / previous suggestion |
| `Ctrl-f` / `Ctrl-b` | Scroll docs down / up |
| `Ctrl-e` | Close completion menu |
| `Enter` | Confirm selection |

## Plugin operators (defaults, but not stock vim)

| Key | Plugin | Action |
|-----|--------|--------|
| `gcc` | Comment.nvim | Toggle comment on line |
| `gc{motion}` / `gc` (visual) | Comment.nvim | Toggle comment over motion/selection |
| `gr{motion}` | ReplaceWithRegister | Replace motion with register contents (e.g. `griw`) |
| `ys{motion}{char}` | vim-surround | Add surrounding (e.g. `ysiw"`) |
| `cs{old}{new}` | vim-surround | Change surrounding (e.g. `cs"'`) |
| `ds{char}` | vim-surround | Delete surrounding (e.g. `ds"`) |
