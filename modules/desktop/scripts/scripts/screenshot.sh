#!/usr/bin/env bash
# Usage: screenshot [copy|save]
#   copy  - select region, copy to clipboard
#   save  - select region, save to ~/Pictures/Screenshots/

MODE="${1:-copy}"
DIR="$HOME/Pictures/Screenshots"
FILE="$DIR/$(date +'%Y-%m-%d_%H-%M-%S').png"

case "$MODE" in
  save)
    mkdir -p "$DIR"
    REGION=$(slurp) || exit 1
    grim -g "$REGION" "$FILE" && notify-send "Screenshot saved" "$FILE"
    ;;
  copy|*)
    REGION=$(slurp) || exit 1
    grim -g "$REGION" - | wl-copy && notify-send "Screenshot copied to clipboard"
    ;;
esac
