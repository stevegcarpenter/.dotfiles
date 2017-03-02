# common .bashrc

# If not running interactively, don't do anything
if [[ $- != *i* ]]; then
  return
fi

# Conditionally source some other files/symlinks
declare -a bashfiles
bashfiles=(/etc/bashrc ~/.bashrc_custom ~/.alias)
for f in ${bashfiles[@]}; do
  if [[ -f $f ]]; then
    # source it
    . "$f"
  fi
done

EDITOR=vim
VISUAL=vim

export SHELL
export PATH
export EDITOR
export VISUAL
export LD_LIBRARY_PATH
export PKG_CONFIG_PATH
