#!/bin/bash

# Dock setup script
# Requires: brew install dockutil

if ! command -v dockutil &> /dev/null; then
  echo "dockutil not found. Install it with: brew install dockutil"
  exit 1
fi

echo "Setting up Dock..."

# Clear existing dock
dockutil --remove all --no-restart

# Add apps in order
dockutil --add /Applications/Google\ Chrome.app --no-restart
dockutil --add /Applications/Obsidian.app --no-restart
dockutil --add /Applications/Figma.app --no-restart
dockutil --add /Applications/Ghostty.app --no-restart
dockutil --add /Applications/Spotify.app --no-restart

# Dock appearance settings
defaults write com.apple.dock tilesize -int 49
defaults write com.apple.dock magnification -bool true
defaults write com.apple.dock largesize -int 89
defaults write com.apple.dock autohide -bool false

# Restart Dock to apply changes
killall Dock

echo "Dock configured!"
