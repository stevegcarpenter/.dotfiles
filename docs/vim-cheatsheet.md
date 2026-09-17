# Vim Cheat Sheet (custom bindings only)

> **Leader is `Space`.** This is for plain `vim` (`~/.vimrc` sources
> `~/.vim.nvim.d/*.rc`; plugins via vim-plug in `~/.vim/plugged`). Neovim has
> a separate config and its own sheet (`nvim-cheatsheet.md`). Only
> non-standard/custom bindings and plugin commands are listed — stock vim
> motions are omitted.

## General (`.keymap.rc`)

| Key | Mode | Action |
|-----|------|--------|
| `jj` / `kk` / `JJ` / `KK` | i | Leave insert mode |
| `<leader>w` | n | Save file |
| `<leader>q` | n | Force-quit window (`:quit!` — discards unsaved changes) |
| `<leader>n` | n | Clear search highlights |
| `<leader>e` | n | Prompt `:e ` to open a file by path |
| `<leader>y` | v | Yank selection to the system clipboard (`"+`) |
| `<leader>p` / `<leader><leader>p` | n | Paste mode on / off |
| `<leader>?` | n | Open this cheat sheet (`:Cheatsheet [name]`, tab-completes) |

## Buffers

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Ctrl-k` | Next / previous buffer |
| `<leader><leader>l` | List buffers, then prompt `:buffer ` |
| `<leader>bd` | Delete current buffer |

## Windows / splits

`splitright` is on, so vertical splits open to the right.

| Key | Action |
|-----|--------|
| `<leader>\|` | Vertical split |
| `<leader>-` | Horizontal split |
| `<leader>h/j/k/l` | Move to the split left / down / up / right |
| `<leader>yw` | vim-windowswap: mark this window |
| `<leader>pw` | vim-windowswap: swap the marked window with this one |
| `<leader>ww` | vim-windowswap: mark on first press, swap on second |

## Fuzzy finding & search

| Key / Command | Action |
|-----|--------|
| `<leader>o` | fzf `:Files` in the current directory |
| `<leader>/` | Prompt `:Rg ` — ripgrep search, results in the quickfix list |
| `*` / `#` (visual) | Search forward / backward for the selected text, literally |
| `:Files [dir]` `:GFiles` `:Buffers` `:Lines` `:History` | Other fzf.vim pickers |
| `:Rg <pattern>` / `:RgRoot` | vim-ripgrep search / show the root it searches from |

Inside an fzf window:

| Key | Action |
|-----|--------|
| `Ctrl-j` / `Ctrl-k` | Next / previous result |
| `Enter` | Open in current window |
| `Ctrl-t` / `Ctrl-x` / `Ctrl-v` | Open in new tab / horizontal split / vertical split |

## Git (vim-fugitive, vim-mercenary)

| Command | Action |
|-----|--------|
| `:Git` | Status window — `-` stage/unstage, `=` inline diff, `dv` vertical diff, `cc` commit, `g?` help |
| `:Git blame` | Blame sidebar |
| `:Gdiffsplit` | Diff the buffer against the index |
| `:Gwrite` / `:Gread` | Stage the file / check the file out (discard changes) |
| `:Git <args>` | Run any git command |
| `:HGblame` `:HGdiff` `:HGshow` | Mercurial equivalents |
| `:DiffSaved` | Diff the buffer against what is on disk (custom, `.func.rc`) |

## Editing operators (plugin defaults, but not stock vim)

| Key / Command | Plugin | Action |
|-----|--------|--------|
| `gcc` / `gc{motion}` / `gc` (visual) | vim-commentary | Toggle comments |
| `ys{motion}{char}` / `cs{old}{new}` / `ds{char}` | vim-surround | Add / change / delete surrounding (e.g. `ysiw"`, `cs"'`, `ds"`) |
| `ga{motion}` / `ga` (visual) | vim-easy-align | Interactive align, then pick a delimiter (e.g. `gaip=`, `vipga=`) |
| `Ctrl-n` / `Ctrl-p` / `Ctrl-x` | vim-multiple-cursors | Add cursor at next match / undo last / skip match; `Esc` exits |
| `Ctrl-y ,` (insert) | emmet-vim | Expand the abbreviation before the cursor (e.g. `ul>li*3`) |
| `>` after an opening tag | vim-closetag | Auto-inserts the closing tag in `.html` / `.xhtml` / `.phtml` |
| `(` `[` `{` `"` `'` | auto-pairs | Auto-insert the closing pair |
| `:Autoformat` | vim-autoformat | Format the buffer with the filetype's formatter |
| `:I` / `:II` / `:IA` (visual block) | VisIncr | Turn a column into a sequence: numbers / zero-padded / letters |
| `:Loremipsum [words]` | loremipsum | Insert placeholder text |
| `:Minimap` / `:MinimapClose` / `:MinimapToggle` | vim-minimap | Code minimap sidebar |

## Colorschemes

Default is `deus` (from awesome-vim-colorschemes). vim256-color adds many more.

| Key / Command | Action |
|-----|--------|
| `F8` / `Shift-F8` | Next / previous colorscheme (vim-colorscheme-switcher) |
| `Alt-F8` | Random colorscheme |
| `:NextColorScheme` `:PrevColorScheme` `:RandomColorScheme` | Same, as commands |

## Language plugins

Go (vim-go, active in `.go` buffers; `goimports` runs on save, type info shows on cursor hold):

| Key / Command | Action |
|-----|--------|
| `gd` / `Ctrl-]` | Go to definition |
| `Ctrl-t` | Jump back from definition |
| `K` | Documentation for the symbol under the cursor |
| `]]` / `[[` | Next / previous function |
| `:GoBuild` `:GoTest` `:GoRun` `:GoInfo` `:GoRename` `:GoImports` | Toolchain commands |
| `:GoUpdateBinaries` | Reinstall the helper tools (into `~/.go/bin`) |

Python (python-mode; rope and folding are turned off):

| Key / Command | Action |
|-----|--------|
| `K` | Documentation for the word under the cursor |
| `<leader>r` | Run the current file |
| `<leader>b` | Insert / remove a breakpoint |
| `]]` / `[[` and `]M` / `[M` | Next / previous class and method |
| `aC` / `iC` and `aM` / `iM` | Class and method text objects |
| `:PymodeLint` / `:PymodeLintAuto` | Lint (also runs on save) / auto-fix with autopep8 |

TypeScript (tsuquyomi, needs `typescript` on PATH):

| Key / Command | Action |
|-----|--------|
| `Ctrl-]` / `Ctrl-t` | Go to definition / jump back |
| `Ctrl-^` | References |
| `:TsuQuickFix` `:TsuRenameSymbol` `:TsuImport` | Fix / rename / add import |

coc.nvim (installed from the latest release tag; no keymaps or extensions are configured):

| Key / Command | Action |
|-----|--------|
| `Ctrl-n` / `Ctrl-p` | Next / previous completion while the popup is open |
| `:CocInstall coc-tsserver` | Install a language extension (none are installed by default) |
| `:CocList` `:CocInfo` `:CocConfig` | Browse lists / diagnose / edit `coc-settings.json` |

## Behaviour to know (`.settings.rc`, `.func.rc`, `.plug.set.rc`)

- Saving into a directory that doesn't exist creates it first.
- Git commit messages get spell checking.
- `%` also jumps between matching HTML tags and `if`/`endif` pairs (matchit).
- Trailing whitespace is highlighted dark red; tabs show as `┊`.
- Indent: 2 spaces for ruby / javascript / typescript / html / css, 4 elsewhere;
  `textwidth=79` for C, C++ and markdown; color columns at 79 and 120 for Go.
- Search ignores case unless the pattern has a capital (`smartcase`).
- Buffers can be hidden with unsaved changes; quitting asks before discarding.
- Files changed outside vim reload automatically; long lines don't wrap.
- Swap and backup files live in `~/.vim/swp` and `~/.vim/backup`, not next to the file.
- vim-airline draws the status line and buffer tabline (`deep_space` theme, powerline glyphs).

## Plugin management (vim-plug)

Plugins are listed in `vim/.vim.nvim.d/.plug.rc` and installed to `~/.vim/plugged`.

| Command | Action |
|-----|--------|
| `:PlugInstall` | Install missing plugins (runs automatically on first launch) |
| `:PlugUpdate` | Update all plugins |
| `:PlugClean` | Remove plugins no longer listed |
| `:PlugStatus` | Show what is installed |
| `:PlugUpgrade` | Update vim-plug itself |

## Known gaps

- `<leader>O` runs `:NERDTree`, but NERDTree is not in the plugin list.
- `<leader>py` maps to vim-prettier, which is not in the plugin list.
- UltiSnips is configured in `.plug.set.rc` but not installed.
- `trevordmiller/nova-vim` no longer exists on GitHub, so `:PlugInstall` reports it as failed.
