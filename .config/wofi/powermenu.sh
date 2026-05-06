#!/bin/bash

chosen=$(printf "Poweroff\nReboot\nLogout\nLock" | wofi --show dmenu --style /home/zaki/.config/wofi/style.css --prompt "Power")

case $chosen in
    Poweroff)
        systemctl poweroff
        ;;
    Reboot)
        systemctl reboot
        ;;
    Logout)
        swaymsg exit
        ;;
    Lock)
        swaylock
        ;;
esac
