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
