#!/usr/bin/env bash

WALL="$1"

awww img "$WALL"

matugen image "$WALL"

niri msg action reload-config

pkill waybar
waybar &

kitty @ set-colors -a ~/.config/kitty/matugen.conf
