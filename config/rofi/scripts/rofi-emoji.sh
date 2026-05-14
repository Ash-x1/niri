#!/usr/bin/env bash

emoji_file="$HOME/.config/rofi/scripts/emojis/all_emojis.txt"

chosen=$(cat "$emoji_file" | rofi -dmenu -i -p "Select Emoji")

if [[ -n "$chosen" ]]; then
    emoji=$(echo "$chosen" | awk '{print $1}')

    echo -n "$emoji" | wl-copy

    wtype "$emoji"
fi
