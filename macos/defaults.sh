#!/bin/bash

# macOS defaults
# Run this on a new Mac to set up preferred system settings

echo "Setting macOS defaults..."

# ===========================================
# Mouse
# ===========================================

# Enable secondary click (right click)
defaults write com.apple.AppleMultitouchMouse MouseButtonMode -string "TwoButton"

# ===========================================
# Keyboard
# ===========================================

# Fast key repeat
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# ===========================================
# Finder
# ===========================================

# Show all file extensions
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show path bar
defaults write com.apple.finder ShowPathbar -bool true

# ===========================================
# Screenshots
# ===========================================

# Save screenshots to Downloads
defaults write com.apple.screencapture location -string "$HOME/Downloads"

# ===========================================
# Default Applications
# ===========================================

# Install duti if not present (for setting default apps)
if ! command -v duti &> /dev/null; then
  echo "Installing duti..."
  brew install duti
fi

# Get Cursor bundle ID dynamically
CURSOR_BUNDLE_ID=$(osascript -e 'id of app "Cursor"' 2>/dev/null)

if [ -z "$CURSOR_BUNDLE_ID" ]; then
  echo "Cursor not installed, skipping default app setup"
else

# Set Cursor as default for common dev file types
echo "Setting Cursor as default app for dev files..."

# JSON
duti -s $CURSOR_BUNDLE_ID public.json all

# Plain text
duti -s $CURSOR_BUNDLE_ID public.plain-text all

# Shell scripts
duti -s $CURSOR_BUNDLE_ID public.shell-script all

# XML
duti -s $CURSOR_BUNDLE_ID public.xml all

# YAML
duti -s $CURSOR_BUNDLE_ID public.yaml all

# Markdown
duti -s $CURSOR_BUNDLE_ID net.daringfireball.markdown all

# SVG
duti -s $CURSOR_BUNDLE_ID public.svg-image all

# Source code
duti -s $CURSOR_BUNDLE_ID public.source-code all

# CSS
duti -s $CURSOR_BUNDLE_ID public.css all

# JavaScript
duti -s $CURSOR_BUNDLE_ID com.netscape.javascript-source all

# TypeScript (may not work on all systems)
duti -s $CURSOR_BUNDLE_ID com.microsoft.typescript all 2>/dev/null
fi

# ===========================================
# Apply changes
# ===========================================

# Restart affected applications
killall Finder 2>/dev/null
killall SystemUIServer 2>/dev/null

echo "Done! Some changes may require a logout/restart to take effect."
