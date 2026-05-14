##!/bin/bash

# Create mkdir -p "$HOME/.cache/rofi_wallpapers"
#
WALL_PATH_FILE="$HOME/.cache/last_wallpaper"
# Make a symlink
ROFI_SYMLINK="$HOME/.config/rofi/current_rofi_wall/current_rofi_wallpaper"

# Save image
ROFI_CACHE_DIR="$HOME/.cache/rofi_wallpapers"
mkdir -p "$ROFI_CACHE_DIR" # Make sure if it's available

# =======================================================
# Check path
# =======================================================

if [ ! -f "$WALL_PATH_FILE" ]; then
    echo "update-rofi-wall: last_wallpaper file not found" >&2
    exit 1
fi

# Read path of image
IMG_PATH_FULL="$(cat "$WALL_PATH_FILE")"

if [ ! -f "$IMG_PATH_FULL" ]; then
    echo "update-rofi-wall: original image not found: $IMG_PATH_FULL" >&2
    exit 2
fi

# =======================================================
# Analyzing thumbnail image (caching)
# =======================================================

IMG_HASH=$(echo "$IMG_PATH_FULL" | sha256sum | awk '{print $1}')
THUMBNAIL_PATH="$ROFI_CACHE_DIR/${IMG_HASH}.jpg"

if [ ! -f "$THUMBNAIL_PATH" ]; then
    echo "update-rofi-wall: Creating new thumbnail for $IMG_PATH_FULL..." >&2

    if command -v convert &> /dev/null; then
        convert "$IMG_PATH_FULL" -resize 1920x1080 -quality 85 "$THUMBNAIL_PATH"

        if [ $? -ne 0 ]; then
            echo "update-rofi-wall: Error running 'convert'. Is ImageMagick installed?" >&2
            exit 3
        fi
    else
        echo "update-rofi-wall: 'convert' command not found. Please install ImageMagick." >&2
        exit 4
    fi
fi

ln -sf -- "$THUMBNAIL_PATH" "$ROFI_SYMLINK"

exit 0
