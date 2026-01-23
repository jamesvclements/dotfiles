#!/bin/bash

# Check for dotfiles updates, auto-apply safe changes, notify for manual ones

DOTFILES_DIR="$HOME/.dotfiles"

cd "$DOTFILES_DIR" || exit 1

# Fetch latest from remote
git fetch origin main --quiet

# Check if we're behind
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" != "$REMOTE" ]; then
  # Get list of changed files before pulling
  CHANGED_FILES=$(git diff --name-only HEAD origin/main)

  # Pull the changes
  git pull --quiet

  # ===========================================
  # Auto-apply safe stuff (symlinks)
  # ===========================================

  # Zsh
  ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc

  # Spaceship
  ln -sf "$DOTFILES_DIR/spaceship/spaceshiprc.zsh" ~/.spaceshiprc.zsh

  # Gitignore
  ln -sf "$DOTFILES_DIR/gitignore_global" ~/.gitignore_global
  git config --global core.excludesfile ~/.gitignore_global

  # Ghostty
  mkdir -p ~/.config/ghostty
  ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config

  # Cursor
  CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
  mkdir -p "$CURSOR_USER_DIR"
  ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
  ln -sf "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

  # ===========================================
  # Check if manual action needed
  # ===========================================

  # Check if Brewfile changed
  if echo "$CHANGED_FILES" | grep -q "Brewfile"; then
    osascript << 'EOF'
set theCommand to "brew bundle --file=~/.dotfiles/Brewfile"
set dialogResult to display dialog "Run this command:

" & theCommand with title "Dotfiles Updated" buttons {"Copy", "Dismiss"} default button "Copy"

if button returned of dialogResult is "Copy" then
    set the clipboard to theCommand
end if
EOF
  fi

  # Check if macOS defaults changed
  if echo "$CHANGED_FILES" | grep -q "macos/defaults.sh"; then
    osascript << 'EOF'
set theCommand to "~/.dotfiles/macos/defaults.sh"
set dialogResult to display dialog "Run this command:

" & theCommand with title "macOS Settings Updated" buttons {"Copy", "Dismiss"} default button "Copy"

if button returned of dialogResult is "Copy" then
    set the clipboard to theCommand
end if
EOF
  fi
fi
