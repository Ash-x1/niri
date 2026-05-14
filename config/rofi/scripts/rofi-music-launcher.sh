#!/bin/bash

# Music direc
music_dir="$HOME/Music/Personal"

#supported files type
mapfile -t music_paths < <(find "$music_dir" -type f \( -iname "*.mp3" -o -iname "*.m4a" -o -iname "*.mp4" -o -iname "*.opus" \))

#check if files are available
[ ${#music_paths[@]} -eq 0 ] && notify-send "ROFI Music" "Nothing to show here" && exit

#listing songs with name only (this one fixes the damn problem of showing all path...)
music_names=()
declare -A name_to_path
for path in "${music_paths[@]}"; do
    name=$(basename "$path")
    music_names+=("$name")
    name_to_path["$name"]="$path"
done

#support of multiselect in rofi (shift+enter don't forget)
selected_names=$(printf "%s\n" "${music_names[@]}" | rofi -dmenu -multi-select -i -p "Choose what to play:")

#check
[ -z "$selected_names" ] && exit

#showing only names again...i don't remember
selected_paths=()
while IFS= read -r name; do
    path="${name_to_path[$name]}"
    # check path
    if [ -n "$path" ]; then
        selected_paths+=("$path")
    fi
done <<< "$selected_names"

#in case i faced problems in the future
echo "Selected files: ${selected_paths[@]}" >> /tmp/rofi-vlc-debug.log

#playing songs one after one not all at same time
printf '%s\n' "${selected_paths[@]}" | xargs -d '\n' vlc --intf dummy --no-video &

