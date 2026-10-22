#!/usr/bin/env bash
# Waybar custom/ethernet equivalent.
if grep -lq up /sys/class/net/en*/operstate 2>/dev/null; then
    printf '󰈁 Ethernet: Connected'
else
    printf '󰈂 Ethernet: Disconnected'
fi
