# dotfiles

My macOS setup. One command to install everything on a new Mac.

## Setup

```bash
git clone https://github.com/jamesvclements/dotfiles.git ~/.dotfiles && ~/.dotfiles/setup.sh
```

This will:

1. **Install apps** via Homebrew (Cursor, Ghostty, Chrome, Slack, etc.)
2. **Link config files** (zsh, Ghostty, Cursor settings/keybindings)
3. **Set macOS defaults** (screenshots to Downloads, secondary click, default apps)
4. **Enable auto-sync** (checks for updates hourly, auto-applies safe changes)

## What's included

| File | Purpose |
|------|---------|
| `Brewfile` | Apps and CLI tools |
| `zshrc` | Shell config |
| `ghostty/` | Terminal settings |
| `cursor/` | Editor settings and keybindings |
| `spaceship/` | Prompt config |
| `macos/defaults.sh` | System preferences |
| `gitignore_global` | Global git ignores |

## Sync across Macs

After setup, changes sync automatically:

- **Config files** (zsh, Ghostty, Cursor) → applied automatically
- **New apps** (Brewfile changes) → shows dialog with command to run
- **macOS settings** → shows dialog with command to run

To manually trigger a sync:

```bash
~/.dotfiles/scripts/sync-check.sh
```
