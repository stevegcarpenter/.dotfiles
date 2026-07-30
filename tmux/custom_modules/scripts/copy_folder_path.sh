#!/usr/bin/env bash
# Copy the focused pane's full current directory to the clipboard, and flash
# the ctp_folder status module's icon and text ("Copied!") briefly as click
# feedback (tmux has no hover events, only clicks, so this is the only way to
# give visual confirmation that the copy happened).
#
# The flash is space-padded to the width of the breadcrumb the pill normally
# shows -- not the full path -- so the pill keeps its width while flashing.
# That width comes from calling folder_path.sh, the same script the module
# itself uses, rather than being recomputed here: the two can't drift.
#
# refresh-client -S with no -t only refreshes "the current client if bound
# to a key" per tmux(1); this script runs detached (run-shell -b), outside
# that context, so the client's tty must be passed in explicitly and used
# as -t, or the status line never actually repaints.

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

path="$1"
client_tty="$2"

printf '%s' "$path" | pbcopy

shown="$("$script_dir/folder_path.sh" "$path")"

# Measure the breadcrumb's display width. The leading "…" is stripped and
# counted as one cell explicitly, so the count is a true cell count whether
# or not the ambient locale has bash counting characters instead of bytes --
# matching how folder_path.sh budgets that same glyph against its cap.
rest="${shown#…}"
shown_len=${#rest}
[ "$rest" != "$shown" ] && shown_len=$((shown_len + 1))

msg="Copied!"
msg_len=${#msg}
if [ "$shown_len" -gt "$msg_len" ]; then
  pad_len=$((shown_len - msg_len))
  msg="${msg}$(printf '%*s' "$pad_len" '')"
fi
# When the breadcrumb is shorter than "Copied!" (a shallow path like /tmp)
# the pill widens by those few cells for the duration of the flash; the
# message is left intact rather than truncated to something unreadable.

tmux set-option -g @catppuccin_ctp_folder_flash "$msg"
tmux refresh-client -S -t "$client_tty"
sleep 1.5
tmux set-option -g @catppuccin_ctp_folder_flash ''
tmux refresh-client -S -t "$client_tty"
