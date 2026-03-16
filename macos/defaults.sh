#!/bin/bash

# macOS defaults
# Run this on a new Mac to set up preferred system settings

echo "Setting macOS defaults..."

# ===========================================
# Trackpad
# ===========================================

# Tap to click
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true

# Natural scrolling
defaults write NSGlobalDomain com.apple.swipescrolldirection -bool true

# Tracking speed (0.0 to 3.0)
defaults write NSGlobalDomain com.apple.trackpad.scaling -float 2

# Light click threshold (0 = light, 1 = medium, 2 = firm)
defaults write com.apple.AppleMultitouchTrackpad FirstClickThreshold -int 0
defaults write com.apple.AppleMultitouchTrackpad SecondClickThreshold -int 0

# Force click (haptic feedback)
defaults write com.apple.AppleMultitouchTrackpad ActuateDetents -int 1
defaults write com.apple.AppleMultitouchTrackpad ForceSuppressed -bool false

# Silent clicking (0 = normal, 1 = silent)
defaults write com.apple.AppleMultitouchTrackpad ActuationStrength -int 0

# Two-finger right click
defaults write com.apple.AppleMultitouchTrackpad TrackpadRightClick -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRightClick -bool true

# Pinch to zoom
defaults write com.apple.AppleMultitouchTrackpad TrackpadPinch -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadPinch -bool true

# Smart zoom (two-finger double tap)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerDoubleTapGesture -int 1
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerDoubleTapGesture -int 1

# Rotate
defaults write com.apple.AppleMultitouchTrackpad TrackpadRotate -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadRotate -bool true

# Swipe between pages (two fingers)
defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true

# Notification Center swipe (two-finger from right edge)
defaults write com.apple.AppleMultitouchTrackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadTwoFingerFromRightEdgeSwipeGesture -int 3

# Three-finger tap for Look Up
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerTapGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerTapGesture -int 2

# Mission Control (three-finger swipe up)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerVertSwipeGesture -int 2

# App Exposé (three-finger swipe down — same gesture group as Mission Control)
# Value 2 = enabled for both vert swipe gestures above

# Swipe between full-screen apps (three-finger horizontal)
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 2

# Launchpad & Show Desktop (four-finger pinch)
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerPinchGesture -int 2
defaults write com.apple.AppleMultitouchTrackpad TrackpadFiveFingerPinchGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFiveFingerPinchGesture -int 2

# Four-finger horizontal swipe (spaces)
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerHorizSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerHorizSwipeGesture -int 2

# Four-finger vertical swipe
defaults write com.apple.AppleMultitouchTrackpad TrackpadFourFingerVertSwipeGesture -int 2
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadFourFingerVertSwipeGesture -int 2

# ===========================================
# Universal Control
# ===========================================

# Enable Universal Control (requires same iCloud account across devices)
defaults write com.apple.universalcontrol Disable -bool false
defaults write com.apple.universalcontrol DisableMagicEdges -bool false

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
