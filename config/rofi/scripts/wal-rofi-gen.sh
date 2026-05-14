#!/usr/bin/env bash
WAL_DIR="$HOME/.cache/wal"
JSON="$WAL_DIR/colors.json"
RASI="$WAL_DIR/colors.rasi"

if [ ! -f "$JSON" ]; then
  echo "Error: $JSON not found."
  exit 1
fi

bg=$(jq -r '.special.background // empty' "$JSON")
fg=$(jq -r '.special.foreground // empty' "$JSON")
bg_alt=$(jq -r '.special.cursor // .special.background // empty' "$JSON")

{
  printf "* {\n"
  printf "    background: %s;\n" "$bg"
  printf "    foreground: %s;\n" "$fg"
  printf "    background-alt: %s;\n" "$bg_alt"
  for i in $(seq 0 15); do
    color=$(jq -r ".colors.color${i} // .colors[${i}] // empty" "$JSON")
    printf "    color%s: %s;\n" "$i" "$color"
  done
  printf "}\n"
} > "$RASI"

echo "Generated $RASI"

