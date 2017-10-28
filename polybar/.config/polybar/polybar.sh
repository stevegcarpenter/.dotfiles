#!/usr/bin/env sh

# Terminate already running bar instances
killall -q polybar

# Wait until the processes have been shut down
while pgrep -x polybar >/dev/null; do sleep 1; done

# Launch polybar
polybar primary &
# Attemp to launch external monitor polybar (Fails if extmon isn't present)
polybar extmon &
