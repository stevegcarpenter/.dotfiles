# .bashrc

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# Source global definitions
if [[ -f /etc/bashrc ]]; then
  . /etc/bashrc
fi

# small hack to see if we are on a work pc or not
if [[ -d /opt/xkl/env/1.2/bin ]]; then
  # User specific environment and startup programs
  PATH=$PATH:$HOME/.scarpenter/bin
  PATH=/opt/xkl/env/1.2/bin:$PATH
  # Support new build environment
  PATH=$PATH:/opt/xkl/tools
  PATH=$PATH:/opt/xkl/tools/bin
  LD_LIBRARY_PATH=$HOME/.scarpenter/lib
  PKG_CONFIG_PATH=$HOME/.scarpenter/lib/pkgconfig
else
  PS1='[\u@\h \W]\$ '
  export TERM=xterm-256color
  [ -n  "$TMUX" ] && export TERM=screen-256color
  export BROWSER=google-chrome-stable
fi

EDITOR=vim
VISUAL=vim

export SHELL
export PATH
export EDITOR
export VISUAL
export LD_LIBRARY_PATH
export PKG_CONFIG_PATH

# Load all desired aliases
test -s ~/.alias && . ~/.alias || true