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
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
ln -sf "$DOTFILES_DIR/ghostty/config" "$HOME/Library/Application Support/com.mitchellh.ghostty/config"

# ===========================================
# Editor (Cursor)
# ===========================================

CURSOR_USER_DIR="$HOME/Library/Application Support/Cursor/User"
mkdir -p "$CURSOR_USER_DIR"

ln -sf "$DOTFILES_DIR/cursor/settings.json" "$CURSOR_USER_DIR/settings.json"
ln -sf "$DOTFILES_DIR/cursor/keybindings.json" "$CURSOR_USER_DIR/keybindings.json"

# ===========================================
# Node (fnm)
# ===========================================

# Default global packages for new Node versions
FNM_DIR="${FNM_DIR:-$HOME/Library/Application Support/fnm}"
mkdir -p "$FNM_DIR"
ln -sf "$DOTFILES_DIR/fnm/default-packages" "$FNM_DIR/default-packages"

# Install global packages on current Node if missing
if command -v npm &> /dev/null; then
  INSTALLED=$(npm ls -g --depth=0 --parseable 2>/dev/null | xargs -I{} basename {})
  MISSING=()
  while IFS= read -r pkg; do
    [ -z "$pkg" ] && continue
    PKG_NAME=$(echo "$pkg" | sed 's/@[^/]*$//')  # strip version if any
    if ! echo "$INSTALLED" | grep -q "$(basename "$PKG_NAME")"; then
      MISSING+=("$pkg")
    fi
  done < "$DOTFILES_DIR/fnm/default-packages"

  if [ ${#MISSING[@]} -gt 0 ]; then
    echo "Missing global npm packages: ${MISSING[*]}"
    read -p "Install them? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
      npm install -g "${MISSING[@]}"
    fi
  fi
fi

# ===========================================
# AI Tools (Claude Code + Cursor)
# ===========================================

# --- Claude Code ---
mkdir -p "$HOME/.claude"
CLAUDE_HAD_CUSTOM_SETTINGS=false

# Backup existing settings if present and not already a symlink
if [ -f "$HOME/.claude/settings.json" ] && [ ! -L "$HOME/.claude/settings.json" ]; then
  mv "$HOME/.claude/settings.json" "$HOME/.claude/settings.backup.json"
  echo "Backed up existing ~/.claude/settings.json to settings.backup.json"
  CLAUDE_HAD_CUSTOM_SETTINGS=true
fi

ln -sf "$DOTFILES_DIR/claude/settings.json" "$HOME/.claude/settings.json"

# --- Cursor ---
mkdir -p "$HOME/.cursor"

# --- Shared: MCP servers ---
# Backup existing mcp.json files if not already symlinks
if [ -f "$HOME/.mcp.json" ] && [ ! -L "$HOME/.mcp.json" ]; then
  mv "$HOME/.mcp.json" "$HOME/.mcp.backup.json"
  echo "Backed up existing ~/.mcp.json to ~/.mcp.backup.json"
fi
if [ -f "$HOME/.cursor/mcp.json" ] && [ ! -L "$HOME/.cursor/mcp.json" ]; then
  mv "$HOME/.cursor/mcp.json" "$HOME/.cursor/mcp.backup.json"
  echo "Backed up existing ~/.cursor/mcp.json to ~/.cursor/mcp.backup.json"
fi

ln -sf "$DOTFILES_DIR/mcp.json" "$HOME/.mcp.json"
ln -sf "$DOTFILES_DIR/mcp.json" "$HOME/.cursor/mcp.json"

# --- Shared: Skills ---
# Symlink entire skills directory (individual symlinks don't work in Cursor)
rm -rf "$HOME/.claude/skills" 2>/dev/null
rm -rf "$HOME/.cursor/skills" 2>/dev/null
ln -s "$DOTFILES_DIR/skills" "$HOME/.claude/skills"
ln -s "$DOTFILES_DIR/skills" "$HOME/.cursor/skills"

# Install AI skills via npx
read -p "Install AI skills (browser, react-best-practices, web-design-guidelines, skill-creator)? (y/n) " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
  echo "Installing skills..."
  npx -y skills add https://github.com/vercel-labs/agent-browser --skill agent-browser --agent claude-code --global --yes
  npx -y skills add https://github.com/vercel-labs/agent-skills --skill vercel-react-best-practices --skill web-design-guidelines --agent claude-code --global --yes
  npx -y skills add https://github.com/anthropics/skills --skill skill-creator --agent claude-code --global --yes

  # Install agent-browser CLI and Chromium for browser skill
  if ! command -v agent-browser &> /dev/null; then
    echo "Installing agent-browser CLI..."
    npm install -g agent-browser
  fi

  # Fix darwin-arm64 binary permissions (npm package bug)
  AGENT_BROWSER_BIN="$(npm root -g)/agent-browser/bin/agent-browser-darwin-arm64"
  if [ -f "$AGENT_BROWSER_BIN" ] && [ ! -x "$AGENT_BROWSER_BIN" ]; then
    chmod +x "$AGENT_BROWSER_BIN"
  fi

  # Install Chromium if not present
  if ! agent-browser --version &>/dev/null; then
    echo "agent-browser binary issue, trying to fix..."
    chmod +x "$AGENT_BROWSER_BIN" 2>/dev/null
  fi

  if [ ! -d "$HOME/Library/Caches/ms-playwright/chromium-"* ] 2>/dev/null; then
    echo "Installing Chromium for agent-browser..."
    agent-browser install
  fi
fi

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
if [ "$CLAUDE_HAD_CUSTOM_SETTINGS" = true ]; then
  echo "CLAUDE CODE:"
  echo "  Your existing permissions were backed up to:"
  echo "  ~/.claude/settings.backup.json"
  echo "  Move any custom permissions to ~/.claude/settings.local.json"
  echo ""
fi
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
