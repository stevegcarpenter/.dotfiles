#!/usr/bin/env bash
# Copy the focused pane's full current directory to the clipboard, and
# flash the ctp_folder status module's icon to a checkmark briefly as click
# feedback (tmux has no hover events, only clicks, so this is the only way
# to give visual confirmation that the copy happened). The path text itself
# is left alone on purpose - swapping it changed the pill's width, which was
# distracting.
#
# refresh-client -S with no -t only refreshes "the current client if bound
# to a key" per tmux(1); this script runs detached (run-shell -b), outside
# that context, so the client's tty must be passed in explicitly and used
# as -t, or the status line never actually repaints.

path="$1"
client_tty="$2"

printf '%s' "$path" | pbcopy

tmux set-option -g @catppuccin_ctp_folder_flash 'on'
tmux refresh-client -S -t "$client_tty"
sleep 1.2
tmux set-option -g @catppuccin_ctp_folder_flash ''
tmux refresh-client -S -t "$client_tty"
