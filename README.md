# dotfiles

Personal configuration files, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Layout

Each top-level directory is a stow "package" whose contents mirror `$HOME`:

| Package  | Provides                                                        |
| -------- | --------------------------------------------------------------- |
| `cursor` | `~/Library/Application Support/Cursor/User/settings.json`       |
| `emacs`  | `~/.emacs`                                                      |
| `git`    | `~/.gitconfig`                                                  |
| `system` | `~/.system/` (shell aliases and extra config)                   |
| `tmux`   | `~/.tmux.conf`                                                  |
| `vim`    | `~/.vimrc`, `~/.vim.nvim.d/`, `~/.config/nvim/`                 |
| `zsh`    | `~/.zshrc`                                                      |

`scripts/` is not a stow package — it holds standalone helper scripts
(add to `PATH` or call directly).

The `cursor` package also carries `extensions.txt` (see below), which is
kept out of `$HOME` by `cursor/.stow-local-ignore`.

## Setup on a new machine

```sh
brew install stow          # macOS
git clone https://github.com/stevegcarpenter/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
stow cursor emacs git system tmux vim zsh
```

`stow <package>` symlinks that package's files into the parent directory
(`$HOME` when the repo lives at `~/.dotfiles`). Use `stow -D <package>` to
remove the symlinks and `stow -R <package>` to re-link after moving files
around. If a real file already exists at a target path, stow refuses to
overwrite it — move the file aside first, or run `stow --adopt <package>`
to pull the existing file into the repo and review the diff.

## Neovim

The nvim config (in the `vim` package) uses [lazy.nvim](https://github.com/folke/lazy.nvim)
as its plugin manager. It requires Neovim **0.11+** (it uses the
`vim.lsp.config` API), plus `git`, `make` and a C compiler (for
telescope-fzf-native and treesitter parsers), and `node` (for the
JS/TS language servers installed by mason).

On first launch lazy.nvim bootstraps itself and installs all plugins;
mason then installs the LSP servers, formatters, and linters in the
background — give it a minute and check progress with `:Mason`.

### Plugin versions are pinned in `lazy-lock.json`

The repo only names the plugins; the exact working versions are pinned
in `vim/.config/nvim/lazy-lock.json`. Because plugins are cloned into
`~/.local/share/nvim/` — *outside this repo* — a machine's plugin state
can drift or break even when the repo is fully up to date. Two rules
keep machines in sync:

- **After pulling** changes to the lock file, run `:Lazy restore` to
  check every plugin out to the pinned versions.
- **To upgrade plugins**, run `:Lazy update`, confirm nvim still works,
  and commit the resulting `lazy-lock.json` diff like any other
  dependency bump. Don't hand-edit the file.

### Migrating a machine from the old packer setup

Before July 2026 this config used packer.nvim. Packer leaves state
behind that is not managed by stow or lazy.nvim and causes startup
errors (`packer_compiled` / treesitter / mason-lspconfig failures) if
it lingers. On any machine that ever ran the old config, delete it:

```sh
rm -rf ~/.config/nvim/plugin            # stale packer_compiled.lua (not a stow symlink)
rm -rf ~/.local/share/nvim/site/pack/packer
```

Then start nvim and run `:Lazy restore`. If weirdness persists, the
nuclear option is `rm -rf ~/.local/share/nvim ~/.local/state/nvim`
followed by a fresh launch — everything in there is reinstallable.

## Cursor extensions

The extensions installed in [Cursor](https://cursor.com) are tracked as a
plain list of IDs in `cursor/extensions.txt` — no binaries, each one is
downloaded from the marketplace at install time.

```sh
scripts/cursor-extensions export    # snapshot currently installed extensions
scripts/cursor-extensions install   # install everything in the list (new machine)
```

The exported list is sorted, so `git diff` after an export shows exactly
which extensions were added or removed. The `cursor` CLI must be on `PATH`:
in Cursor, run **Shell Command: Install 'cursor' command in PATH** from the
command palette.

Cursor's `settings.json` is tracked in the `cursor` stow package and
symlinked into `~/Library/Application Support/Cursor/User/` by
`stow cursor`. Keybindings and snippets in that same directory are not
tracked.
