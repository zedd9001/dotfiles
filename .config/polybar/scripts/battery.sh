#!/usr/bin/env bash
# Battery indicator mirroring the Waybar battery module config:
#   format-charging     "{icon} {capacity}% ({time} to full)"
#   format-plugged      "{icon} {capacity}% (plugged in)"
#   format-full         "{icon} {capacity}% (full)"
#   format-discharging  "{icon} {capacity}% ({time} left)"
# Uses BAT0/ADP0 like the Waybar config, and distinguishes "AC online but not
# charging" (plugged) from a real discharge.

bat="${POLYBAR_BATTERY:-BAT0}"
adp="${POLYBAR_ADAPTER:-ADP0}"
base="/sys/class/power_supply"

[ -r "$base/$bat/capacity" ] || exit 0

capacity="$(cat "$base/$bat/capacity")"
status="$(cat "$base/$bat/status" 2>/dev/null)"
online=0
[ -r "$base/$adp/online" ] && online="$(cat "$base/$adp/online")"

state="discharging"
if [ "$status" = "Full" ] || [ "$capacity" -ge 100 ]; then
    state="full"
elif [ "$status" = "Charging" ]; then
    state="charging"
elif [ "$online" = "1" ]; then
    state="plugged"
fi

# Estimate remaining time. energy_* is in uWh, power_now in uW; charge_* is in
# uAh, current_now in uA. Both give hours as amount / rate.
amount=""
rate=""
if [ -r "$base/$bat/energy_now" ] && [ -r "$base/$bat/power_now" ]; then
    amount="$(cat "$base/$bat/energy_now")"
    rate="$(cat "$base/$bat/power_now")"
    if [ "$state" = "charging" ] && [ -r "$base/$bat/energy_full" ]; then
        amount="$(( $(cat "$base/$bat/energy_full") - amount ))"
    fi
elif [ -r "$base/$bat/charge_now" ] && [ -r "$base/$bat/current_now" ]; then
    amount="$(cat "$base/$bat/charge_now")"
    rate="$(cat "$base/$bat/current_now")"
    if [ "$state" = "charging" ] && [ -r "$base/$bat/charge_full" ]; then
        amount="$(( $(cat "$base/$bat/charge_full") - amount ))"
    fi
fi

time_left=""
if [ -n "$amount" ] && [ -n "$rate" ] && [ "$rate" -gt 0 ] 2>/dev/null; then
    minutes=$(( amount * 60 / rate ))
    hours=$(( minutes / 60 ))
    mins=$(( minutes % 60 ))
    if [ "$hours" -gt 0 ]; then
        time_left="${hours}h ${mins}m"
    else
        time_left="${mins}m"
    fi
fi

icons=(󰂎 󰁺 󰁻 󰁼 󰁽 󰁾 󰁿 󰂀 󰂁 󰂂 󰁹)
idx=$(( capacity / 10 ))
[ "$idx" -gt 10 ] && idx=10
icon="${icons[$idx]}"

if [ "$capacity" -le 10 ]; then
    color="#C73E3E"
elif [ "$capacity" -le 20 ]; then
    color="#E5C07B"
elif [ "$state" = "charging" ] || [ "$state" = "plugged" ] || [ "$state" = "full" ]; then
    color="#98C379"
else
    color="#9C9BAA"
fi

case "$state" in
    charging)
        [ -n "$time_left" ] && suffix=" (${time_left} to full)" || suffix=""
        ;;
    plugged)
        suffix=" (plugged in)"
        ;;
    full)
        suffix=" (full)"
        ;;
    *)
        [ -n "$time_left" ] && suffix=" (${time_left} left)" || suffix=""
        ;;
esac

printf '%%{F%s}%s %s%%%s%%{F-}' "$color" "$icon" "$capacity" "$suffix"
