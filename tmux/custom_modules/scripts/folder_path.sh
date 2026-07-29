#!/usr/bin/env bash
# Print the last 3 segments of the given path (or fewer, if the path is
# shorter). Used by the ctp_folder status module to show a short breadcrumb
# for the focused pane's current directory without overflowing the bar.

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

if [ "$n" -gt 3 ]; then
  start=$((n - 3))
  out="…"
else
  start=0
  out=""
fi

for ((i = start; i < n; i++)); do
  out="${out}/${segments[$i]}"
done

printf '%s' "$out"
