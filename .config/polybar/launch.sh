#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use
# polybar-msg cmd quit

# Launch bar1 on all monitors
echo "---" | tee -a /tmp/polybar1.log
#polybar bar1 >>/tmp/polybar1.log 2>&1 & disown

if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload bar1 >>/tmp/polybar1.log 2>&1 & disown
  done
else
  polybar --reload bar1 >>/tmp/polybar1.log 2>&1 & disown
fi

echo "Bars launched..."