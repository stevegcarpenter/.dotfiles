# zsh plug section
##############################################################################
# packages
export ZPLUG_HOME=/usr/local/opt/zplug
source $ZPLUG_HOME/init.zsh

# Supports oh-my-zsh plugins and the like
zplug "plugins/git",   from:oh-my-zsh
# Load theme file
zplug 'dracula/zsh', as:theme
# Remind about aliases
# zplug "MichaelAquilina/zsh-you-should-use"

zplug "zsh-users/zsh-syntax-highlighting"
zplug "zsh-users/zsh-autosuggestions"
zplug "zsh-users/zsh-completions"
zplug "zigius/expand-ealias.plugin.zsh"
zplug "paulmelnikow/zsh-startup-timer"
zplug "tysonwolker/iterm-tab-colors"
zplug "desyncr/auto-ls"
zplug "momo-lab/zsh-abbrev-alias"
zplug "arzzen/calc.plugin.zsh"
zplug "peterhurford/up.zsh"
zplug "jimeh/zsh-peco-history"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# Then, source plugins and add commands to $PATH
zplug load

##############################################################################

# configure zsh for emacs keybindings
bindkey -e
# configure auto menu for when command is not found
setopt AUTO_CD
# save history to a file
[ -z "$HISTFILE" ] && HISTFILE="~/.zsh_history"

# editor
export EDITOR=nvim
export VISUAL=nvim

# check here for node_modules
# PATH=$HOME/.node_modules/bin:$PATH
# export npm_config_prefix=$HOME/.node_modules
PATH=$HOME/node_modules/.bin:$PATH

# access doom commands
PATH=$PATH:$HOME/.emacs.d/bin

export PATH

# set TERM appropriately based on whether TMUX is active
if [[ -n  "$TMUX" ]]; then
  export TERM=screen-256color
else
  export TERM=xterm-256color
fi

# fzf fuzzy finder
[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
export FZF_DEFAULT_COMMAND='fd --type f'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

bindkey '^[[A' history-beginning-search-backward
bindkey '^[[B' history-beginning-search-forward

[ -f /usr/local/etc/profile.d/z.sh ] && source /usr/local/etc/profile.d/z.sh

source $HOME/.asdf/asdf.sh
source $HOME/.asdf/completions/asdf.bash

# Conditionally source some other dot files/symlinks
for f in ~/.system/.*; do
  if [[ -f $f ]]; then
    # source it
    . "$f"
  fi
done

export KUBECONFIG="$HOME/.kube/config:$HOME/.outreach/kubeconfig.yaml"
export NODE_EXTRA_CA_CERTS="$HOME/.local/dev-environment/.outreach-ca/tls.crt"
###start-marker|{"name":"orcsource","description":"Allows Outreach specific shell hooks"}
source "$HOME/.outreach/outreachrc.sh"
###end-marker