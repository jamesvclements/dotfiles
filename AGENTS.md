# Agent Context

This is a dotfiles repo for syncing macOS setup across multiple Macs.

## Structure

```
├── Brewfile                 # Homebrew CLI tools and cask apps
├── zshrc                    # Shell config (symlinked to ~/.zshrc)
├── gitignore_global         # Global git ignores
├── ghostty/config           # Ghostty terminal settings
├── spaceship/spaceshiprc.zsh # Zsh prompt config
├── cursor/
│   ├── settings.json        # Cursor editor settings
│   └── keybindings.json     # Cursor keybindings
├── macos/defaults.sh        # macOS system preferences (requires manual run)
├── scripts/
│   ├── sync-check.sh        # Hourly sync checker (runs via launchd)
│   └── com.dotfiles.sync-check.plist # launchd job config
└── setup.sh                 # Main setup script
```

## How it works

1. `setup.sh` is the entry point - installs Homebrew, links configs, sets up sync
2. Config files are symlinked, so edits in ~/.dotfiles propagate everywhere
3. `sync-check.sh` runs hourly via launchd, pulls changes, auto-applies safe stuff (symlinks)
4. Changes to Brewfile or macos/defaults.sh trigger a dialog prompting manual action

## Key behaviors

- **Safe auto-apply**: symlinks for zshrc, ghostty, cursor, spaceship, gitignore
- **Manual action needed**: Brewfile changes (new apps), macos/defaults.sh changes
- **Notifications**: Uses osascript dialogs (not notifications) with Copy/Dismiss buttons

## Adding new configs

1. Add the config file to this repo
2. Add symlink command to both `setup.sh` and `scripts/sync-check.sh`
3. If it requires manual action, add a dialog check in `sync-check.sh`

## Testing

Run sync manually: `~/.dotfiles/scripts/sync-check.sh`
Check launchd status: `launchctl list | grep dotfiles`
View sync logs: `cat /tmp/dotfiles-sync.log`
