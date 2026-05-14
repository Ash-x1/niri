#!/usr/bin/env bash

# rofi-power-menu.sh
# A self-contained power menu for Hyprland using Rofi

set -e
set -u

# Power menu options
options=(" Shutdown" " Reboot" " Logout" " Suspend" " Hibernate" " Lock")

# Map options to actions
declare -A actions
actions["Shutdown"]="systemctl poweroff"
actions["Reboot"]="systemctl reboot"
actions["Logout"]="loginctl terminate-session ${XDG_SESSION_ID-}"
actions["Suspend"]="systemctl suspend"
actions["Hibernate"]="systemctl hibernate"
actions["Lock"]="swaylock"

# Actions requiring confirmation
confirm=("Shutdown" "Reboot" "Logout")

# Show rofi menu
chosen=$(printf '%s\n' "${options[@]}" | rofi -dmenu -i -p "Power Menu")

# Extract the key (without icon)
key=$(echo "$chosen" | sed 's/^[^ ]* //')

if [[ -z "$key" ]]; then
  exit 0
fi

# Check if confirmation is needed
if [[ " ${confirm[*]} " == *" $key "* ]]; then
  confirm_choice=$(echo -e "Yes\nNo" | rofi -dmenu -p "Are you sure?")
  if [[ "$confirm_choice" != "Yes" ]]; then
    exit 0
  fi
fi

# Execute the action
${actions[$key]}
