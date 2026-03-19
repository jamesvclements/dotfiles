#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Restart Universal Control
# @raycast.mode compact
# @raycast.icon 🖥️
# @raycast.packageName System

# Optional parameters:
# @raycast.needsConfirmation false

# Kill and restart Universal Control
killall UniversalControl 2>/dev/null

# Toggle it off and on for good measure
defaults write com.apple.universalcontrol Disable -bool true
sleep 0.5
defaults write com.apple.universalcontrol Disable -bool false

echo "Universal Control restarted"
