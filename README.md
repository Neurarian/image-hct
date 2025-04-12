# image-hct: Material Color scoring utility
Rust utility using the material_colors crate to score colors of e.g., a wallpaper and return the Hue, Chrome, and Tone of its highest scoring color. Used as in conjunction with [matugen](https://github.com/InioX/matugen) to set theme and scheme dynamically based on those HCT values. 
Usage example: 
```bash
#!/bin/bash
 set -euo pipefail

 if [ ! -d ~/Pictures/wallpapers/ ]; then
   wallpaper_path="$HOME/Pictures/default_wallpaper"
   echo "Required directory: $HOME/Pictures/wallpapers not found. Fallback to default wallpaper"
 else
   wallpaper_path="$(fd . "$HOME/Pictures/wallpapers" -t f | shuf -n 1)"
 fi

 apply_hyprpaper() {

   # Preload the wallpaper once, since it doesn't change per monitor
   hyprctl hyprpaper preload "$wallpaper_path"

   # Set wallpaper for each monitor
   hyprctl monitors | rg 'Monitor' | awk '{print $2}' | while read -r monitor; do
   hyprctl hyprpaper wallpaper "$monitor, $wallpaper_path"
   done
 }

 if [ "$(image-hct "$wallpaper_path" tone)" -gt 60 ]; then
   mode="light"
 else
   mode="dark"
 fi

 if [ "$(image-hct "$wallpaper_path" chroma)" -lt 20 ]; then
   scheme="scheme-neutral"
 else
   scheme="scheme-vibrant"
 fi

 # Set Material colortheme

 matugen -t "$scheme" -m "$mode" image "$wallpaper_path"

 # unload previous wallpaper

 hyprctl hyprpaper unload all

 # Set the new wallpaper

 apply_hyprpaper

 # Get wallpaper image name & send notification

 newwall=$(basename "$wallpaper_path")
 notify-send "Colors and Wallpaper updated" "with image $newwall" -i "$wallpaper_path"


echo "DONE!"
```
