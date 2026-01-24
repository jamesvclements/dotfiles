#!/bin/bash

# Dotfiles setup script
# Run this on a new Mac after cloning the repo

DOTFILES_DIR="$HOME/.dotfiles"

echo "Setting up dotfiles..."

# ===========================================
# Homebrew
# ===========================================

if ! command -v brew &> /dev/null; then
  read -p "Homebrew not found. Install it? (y/n) " -n 1 -r
  echo
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
fi

# Check if all packages are already installed (fast check)
if command -v brew &> /dev/null; then
  if HOMEBREW_NO_AUTO_UPDATE=1 brew bundle check --file="$DOTFILES_DIR/Brewfile" &>/dev/null; then
    echo "All Homebrew packages already installed."
  else
    read -p "Some Homebrew packages missing. Install them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      HOMEBREW_NO_AUTO_UPDATE=1 brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade
    fi
  fi
fi

# ===========================================
# Shell
# ===========================================

# Zsh
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc

# Spaceship prompt
ln -sf "$DOTFILES_DIR/spaceship/spaceshiprc.zsh" ~/.spaceshiprc.zsh

# ===========================================
# Git
# ===========================================

# Global gitignore
ln -sf "$DOTFILES_DIR/gitignore_global" ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global

# ===========================================
# Terminal
# ===========================================

# Ghostty
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

# ===========================================
# Editor (Cursor)
# ===========================================

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER_DIR"

ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

# ===========================================
# macOS defaults
# ===========================================

read -p "Apply macOS defaults? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  chmod +x "$DOTFILES_DIR/macos/defaults.sh"
  "$DOTFILES_DIR/macos/defaults.sh"
fi

# ===========================================
# Superwhisper
# ===========================================

# Set toggle recording to Control+Space (instead of default Option+Space)
defaults write com.superduper.superwhisper "KeyboardShortcuts_toggleRecording" -string '{"carbonModifiers":4096,"mouseButtonNumbers":[],"carbonKeyCode":49}'

# ===========================================
# Dock
# ===========================================

read -p "Configure Dock? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  chmod +x "$DOTFILES_DIR/macos/dock.sh"
  "$DOTFILES_DIR/macos/dock.sh"
fi

# ===========================================
# Sync checker (launchd)
# ===========================================

PLIST_SRC="$DOTFILES_DIR/scripts/com.dotfiles.sync-check.plist"
PLIST_DST="$HOME/Library/LaunchAgents/com.dotfiles.sync-check.plist"

# Unload if already loaded
launchctl unload "$PLIST_DST" 2>/dev/null

# Copy and load
cp "$PLIST_SRC" "$PLIST_DST"
launchctl load "$PLIST_DST"

echo ""
echo "============================================="
echo " Setup complete!"
echo "============================================="
echo ""
echo "Dotfiles linked. Sync checker installed."
echo ""
echo "---------------------------------------------"
echo " Manual steps required:"
echo "---------------------------------------------"
echo ""
echo "APPS TO DOWNLOAD MANUALLY:"
echo "  - Cursor: https://cursor.com/download"
echo "  - Tailscale: https://tailscale.com/download"
echo ""
echo "LOGIN ITEMS TO ADD:"
echo "  Open System Settings → General → Login Items → add these:"
echo "  - Dropbox"
echo "  - Raycast"
echo "  - CleanShot X"
echo "  - PixelSnap 2"
echo "  - Superwhisper"
echo ""
echo "  Tip: Open System Settings directly:"
echo "  open x-apple.systempreferences:com.apple.LoginItems-Settings.extension"
echo ""
