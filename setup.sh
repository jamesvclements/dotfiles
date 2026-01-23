#!/bin/bash

# Dotfiles setup script
# Run this on a new Mac after cloning the repo

DOTFILES_DIR="$HOME/.dotfiles"

echo "Setting up dotfiles..."

# ===========================================
# Homebrew
# ===========================================

read -p "Install Homebrew packages and apps? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  if ! command -v brew &> /dev/null; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi
  brew bundle --file="$DOTFILES_DIR/Brewfile"
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

echo "Dotfiles linked!"
