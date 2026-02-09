#!/bin/bash

# Check for dotfiles updates, auto-apply safe changes, notify for manual ones

DOTFILES_DIR="$HOME/.dotfiles"
SYNC_LOG="$DOTFILES_DIR/.sync-log"

cd "$DOTFILES_DIR" || exit 1

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$SYNC_LOG"
}

# Fetch latest from remote
git fetch origin main --quiet

# Check if we're behind
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ]; then
  log "no changes"
  exit 0
fi

if [ "$LOCAL" != "$REMOTE" ]; then
  # Get list of changed files before pulling
  CHANGED_FILES=$(git diff --name-only HEAD origin/main)
  FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

  # Pull the changes
  git pull --quiet

  log "pulled | $FILE_COUNT file(s): $(echo "$CHANGED_FILES" | tr '\n' ' ')"

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
  mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
  ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

  # Cursor
  CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
  mkdir -p "$CURSOR_USER_DIR"
  ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
  ln -sf "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

  # fnm default-packages
  FNM_DIR="${FNM_DIR:-$HOME/Library/Application Support/fnm}"
  mkdir -p "$FNM_DIR"
  ln -sf "$DOTFILES_DIR/fnm/default-packages" "$FNM_DIR/default-packages"

  log "applied | symlinks refreshed"

  # ===========================================
  # Check if manual action needed
  # ===========================================

  # Check if Brewfile changed
  if echo "$CHANGED_FILES" | grep -q "Brewfile"; then
    log "notify | Brewfile changed, prompted for brew bundle"
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
    log "notify | macos/defaults.sh changed, prompted for manual run"
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
