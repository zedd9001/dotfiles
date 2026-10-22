#!/usr/bin/env bash
# Waybar custom/localip equivalent: first global IPv4 on an up interface.
ip -4 addr show scope global up | grep inet | awk '{print $2}' | cut -d/ -f1 | head -1 | sed 's/^/󰯄 /'
