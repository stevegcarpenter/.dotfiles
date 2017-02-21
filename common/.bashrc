#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

PS1='[\u@\h \W]\$ '

export EDITOR=vim
export TERM=xterm-256color
[ -n  "$TMUX" ] && export TERM=screen-256color
export BROWSER=google-chrome-stable

# Load all desired aliases
test -s ~/.alias && . ~/.alias || true
