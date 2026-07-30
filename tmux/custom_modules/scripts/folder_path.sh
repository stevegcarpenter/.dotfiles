#!/usr/bin/env bash
# Print a short breadcrumb for the given path: the last 3 segments, further
# clipped to MAX_LEN display cells. Used by the ctp_folder status module so
# the folder pill has a bounded worst-case width.
#
# The width cap matters because status-right is laid out right-to-left: when
# the bar runs out of room tmux trims the *left* end of status-right, which
# is this pill. Uncapped, a deep path crowds the window list out of the
# middle of the bar entirely. Capping here keeps the window list visible.
#
# This script is the single source of truth for what the pill displays --
# copy_folder_path.sh calls it to size its "Copied!" flash so the pill keeps
# exactly the same width when clicked.

MAX_LEN=40

path="$1"
trimmed="${path%/}"

if [ -z "$trimmed" ]; then
  printf '/'
  exit 0
fi

IFS='/' read -ra parts <<< "$trimmed"
segments=()
for p in "${parts[@]}"; do
  [ -n "$p" ] && segments+=("$p")
done

n=${#segments[@]}

if [ "$n" -eq 0 ]; then
  printf '/'
  exit 0
fi

# Leading "…" marks elided content, from dropped segments and/or the length
# clip below. Tracked as a flag rather than concatenated up front so its one
# display cell can be budgeted against MAX_LEN exactly.
if [ "$n" -gt 3 ]; then
  start=$((n - 3))
  ellipsis=1
else
  start=0
  ellipsis=0
fi

joined=""
for ((i = start; i < n; i++)); do
  joined="${joined}/${segments[$i]}"
done

# Clip to the cap, keeping the tail (the most specific segments). ${#joined}
# is measured on the ellipsis-free string so it is not affected by whether
# the ambient locale counts multibyte characters or bytes; a non-ASCII
# directory name only ever makes this conservative, never overflowing.
if [ "$ellipsis" -eq 1 ]; then
  avail=$((MAX_LEN - 1))
else
  avail=$MAX_LEN
fi

if [ "${#joined}" -gt "$avail" ]; then
  ellipsis=1
  avail=$((MAX_LEN - 1))
  joined="${joined: -avail}"
fi

if [ "$ellipsis" -eq 1 ]; then
  printf '…%s' "$joined"
else
  printf '%s' "$joined"
fi
