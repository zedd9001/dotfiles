# Dotfiles

Dotfiles for my ~~Sway~~ hyprland config  
Hyprland 0.56.x desktop configuration 

## Contents

| Dir | Purpose |
| --- | --- |
| `.config/hypr` | Hyprland compositor: `hyprland.conf`, `hypridle`, `hyprlock`, `hyprpaper` |
| `.config/waybar` | Waybar bar (Hyprland modules + battery) |
| `.config/rofi` | App launcher / theme |
| `.config/alacritty` | Terminal |
| `.config/fontconfig` | Font configuration |
| `wallpaper.jpg` | Wallpaper (move to `~/Pictures/wallpaper.jpg`) |

## Sync

Deploy to `~/.config` with a symlink farm / `stow`, or copy each dir:

```sh
stow -t ~ .config   # from repo root
```
