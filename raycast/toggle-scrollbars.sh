#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Toggle Always Show Scrollbars
# @raycast.mode compact
# @raycast.icon 🖱️
# @raycast.packageName System

# Optional parameters:
# @raycast.needsConfirmation false

# Current value: WhenScrolling, Automatic, or Always
current=$(defaults read NSGlobalDomain AppleShowScrollBars 2>/dev/null)

if [ "$current" = "Always" ]; then
  defaults write NSGlobalDomain AppleShowScrollBars -string "WhenScrolling"
  echo "Scrollbars: Show When Scrolling"
else
  defaults write NSGlobalDomain AppleShowScrollBars -string "Always"
  echo "Scrollbars: Always Show"
fi
