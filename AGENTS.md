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
├── claude/settings.json     # Claude Code settings
├── mcp.json                 # Shared MCP servers (Claude + Cursor)
├── skills/                  # AI skills (gitignored, installed via setup)
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

## AI Skills

The `skills/` directory is gitignored (only `.gitkeep` is tracked). During setup, you're prompted to install skills via `npx skills add`. Answering "Y" installs:

- **agent-browser** - Browser automation (requires `agent-browser` CLI)
- **vercel-react-best-practices** - React/Next.js optimization (57 rules)
- **web-design-guidelines** - UI review against Web Interface Guidelines
- **skill-creator** - Guide for creating new skills

`npx skills add` installs to `~/.agents/skills/` and creates symlinks in `skills/`. Claude Code and Cursor both symlink to `skills/`, so both see the installed skills.

## Testing

Run sync manually: `~/.dotfiles/scripts/sync-check.sh`
Check launchd status: `launchctl list | grep dotfiles`
View sync log: `cat ~/.dotfiles/.sync-log` (gitignored, local audit trail)
