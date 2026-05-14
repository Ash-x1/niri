#!/usr/bin/env bash
set -euo pipefail

# =========================
# Config
# =========================
WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

TRANSITION_DURATION="3"
TRANSITION_FPS="60"

LAST_WALL="$HOME/.cache/current_wallpaper"

# =========================
# Dependencies
# =========================
for dep in rofi awww matugen notify-send; do
  command -v "$dep" >/dev/null 2>&1 || {
    echo "Missing: $dep"
    exit 1
  }
done

# =========================
# Build temp menu file (SAFE + ICONS WORK)
# =========================
tmpfile=$(mktemp)

declare -A map

while IFS= read -r -d '' img; do
  name="$(basename "$img")"

  map["$name"]="$img"

  # rofi format: "display\0icon\x1fpath"
  printf "%s\0icon\x1f%s\n" "$name" "$img" >>"$tmpfile"
done < <(
  find "$WALLPAPER_DIR" -type f \( \
    -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.gif" \
    \) -print0
)

# =========================
# Pick wallpaper
# =========================
chosen=$(
  cat "$tmpfile" | rofi \
    -dmenu \
    -i \
    -p "󰸉 Wallpapers" \
    -show-icons \
    -theme-str 'element-icon { size: 80px; border-radius: 10px; }'
)

rm -f "$tmpfile"

[[ -z "${chosen:-}" ]] && exit 0

# =========================
# Resolve full path
# =========================
selected_wallpaper="${map[$chosen]}"

[[ -z "$selected_wallpaper" ]] && {
  echo "Failed to resolve wallpaper path"
  exit 1
}

# =========================
# Apply wallpaper (awww)
# =========================
awww img "$selected_wallpaper" \
  --transition-type random \
  --transition-duration "$TRANSITION_DURATION" \
  --transition-fps "$TRANSITION_FPS"

# =========================
# Matugen (force palette #1)
# =========================
sleep 0.2

printf "1\n" | matugen image "$selected_wallpaper" \
  --mode dark \
  --type scheme-tonal-spot \
  --prefer saturation \
  --quiet

# =========================
# Save last wallpaper
# =========================
mkdir -p "$(dirname "$LAST_WALL")"
echo "$selected_wallpaper" >"$LAST_WALL"

# =========================
# Notify
# =========================
notify-send "Wallpaper Changed" "$chosen"
