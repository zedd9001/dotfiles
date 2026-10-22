#!/usr/bin/env bash
# Restart Polybar without stacking duplicate instances (used by i3 exec_always).
# Starts one bar per connected output, mirroring Waybar's all-outputs behaviour.

# Serialize invocations: i3 can queue several exec_always entries, and parallel
# runs would otherwise race and leave two bars behind.
if command -v flock >/dev/null 2>&1; then
    exec 9>"${XDG_RUNTIME_DIR:-/tmp}/polybar-launch.lock"
    # Another launch is already in progress; let it do the work.
    flock -n 9 || exit 0
fi

killall -q polybar 2>/dev/null
while pgrep -u "$UID" -x polybar >/dev/null; do
    sleep 0.2
done

if command -v xrandr >/dev/null 2>&1; then
    for monitor in $(xrandr --query | awk '/ connected/{print $1}'); do
        # Close the lock fd in the long-lived bar process.
        MONITOR="$monitor" polybar main >"/tmp/polybar-$monitor.log" 2>&1 9>&- &
    done
else
    polybar main >/tmp/polybar.log 2>&1 9>&- &
fi
