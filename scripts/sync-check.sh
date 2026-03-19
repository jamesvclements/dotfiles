#!/bin/bash

# Auto-sync dotfiles: pull, apply everything, alert only on conflicts

DOTFILES_DIR="$HOME/.dotfiles"
SYNC_LOG="$DOTFILES_DIR/.sync-log"

cd "$DOTFILES_DIR" || exit 1

log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') | $1" >> "$SYNC_LOG"
}

alert() {
  osascript -e "display dialog \"$1\" with title \"Dotfiles Sync\" buttons {\"OK\"} default button \"OK\"" &>/dev/null
}

# Stash any local changes before syncing
STASHED=false
if ! git diff --quiet || ! git diff --cached --quiet; then
  git stash --quiet
  STASHED=true
  log "stashed | local changes stashed before pull"
fi

# Fetch latest from remote
git fetch origin main --quiet

# Check if we're behind
LOCAL=$(git rev-parse HEAD)
REMOTE=$(git rev-parse origin/main)

if [ "$LOCAL" = "$REMOTE" ] && [ "$STASHED" = false ]; then
  log "no changes"
  exit 0
fi

# Pull with rebase to keep history clean
if [ "$LOCAL" != "$REMOTE" ]; then
  CHANGED_FILES=$(git diff --name-only HEAD origin/main)
  FILE_COUNT=$(echo "$CHANGED_FILES" | wc -l | tr -d ' ')

  if ! git pull --rebase --quiet 2>/dev/null; then
    log "CONFLICT | rebase failed, aborting"
    git rebase --abort 2>/dev/null
    alert "Dotfiles sync hit a merge conflict. Run 'cd ~/.dotfiles && git pull' to resolve."
    # Restore stashed changes even on failure
    if [ "$STASHED" = true ]; then
      git stash pop --quiet 2>/dev/null
    fi
    exit 1
  fi

  log "pulled | $FILE_COUNT file(s): $(echo "$CHANGED_FILES" | tr '\n' ' ')"
fi

# Pop stashed changes
if [ "$STASHED" = true ]; then
  if ! git stash pop --quiet 2>/dev/null; then
    log "CONFLICT | stash pop failed, changes remain in stash"
    alert "Dotfiles sync: your local changes conflict with pulled changes. Run 'cd ~/.dotfiles && git stash pop' to resolve."
    exit 1
  fi
  log "unstashed | local changes restored"
fi

# ===========================================
# Auto-apply everything
# ===========================================

# Symlinks
ln -sf "$DOTFILES_DIR/zshrc" ~/.zshrc
ln -sf "$DOTFILES_DIR/spaceship/spaceshiprc.zsh" ~/.spaceshiprc.zsh
ln -sf "$DOTFILES_DIR/gitignore_global" ~/.gitignore_global
git config --global core.excludesfile ~/.gitignore_global
mkdir -p ~/.config/ghostty
ln -sf "$DOTFILES_DIR/ghostty/config" ~/.config/ghostty/config
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"
CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER_DIR"
ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"
FNM_DIR="${FNM_DIR:-$HOME/Library/Application Support/fnm}"
mkdir -p "$FNM_DIR"
ln -sf "$DOTFILES_DIR/fnm/default-packages" "$FNM_DIR/default-packages"
mkdir -p "$HOME/.claude"
ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"
ln -sf "$DOTFILES_DIR/mcp.json" "$HOME/.mcp.json"
mkdir -p "$HOME/.cursor"
ln -sf "$DOTFILES_DIR/mcp.json" "$HOME/.cursor/mcp.json"

log "applied | symlinks refreshed"

# Brewfile — install new stuff only, no upgrades, no cask cleanup
if echo "$CHANGED_FILES" | grep -q "Brewfile"; then
  log "applying | brew bundle (no-upgrade)"
  brew bundle --file="$DOTFILES_DIR/Brewfile" --no-upgrade --quiet 2>/dev/null
  log "applied | brew bundle done"
fi

# macOS defaults
if echo "$CHANGED_FILES" | grep -q "macos/defaults.sh"; then
  log "applying | macos/defaults.sh"
  bash "$DOTFILES_DIR/macos/defaults.sh"
  log "applied | macos/defaults.sh done"
fi
