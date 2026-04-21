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
├── fnm/default-packages     # Global npm packages auto-installed with new Node versions
├── mcp.json                 # Shared MCP servers (Claude + Cursor)
├── skills/                  # AI skills (gitignored, installed via setup)
├── private/                 # Git submodule for private/sensitive configs
│   └── skills/              # Personal skills (tweet-caption, etc.)
├── macos/
│   ├── defaults.sh          # macOS system preferences (trackpad, keyboard, Finder, etc.)
│   └── dock.sh              # Dock apps + appearance (uses dockutil)
└── setup.sh                 # Main setup script
```

## How it works

1. `setup.sh` is the entry point — installs Homebrew, links configs, runs macOS defaults
2. Config files are symlinked, so edits in `~/.dotfiles` propagate everywhere
3. To pull updates on a machine: `cd ~/.dotfiles && git pull` (re-run `./setup.sh` if Brewfile or macos/ changed)

## Adding new configs

1. Add the config file to this repo
2. Add a symlink command to `setup.sh`

## AI Skills

The `skills/` directory is gitignored (only `.gitkeep` is tracked). During setup, you're prompted to install skills via `npx skills add`. Answering "Y" installs:

- **agent-browser** - Browser automation (requires `agent-browser` CLI)
- **vercel-react-best-practices** - React/Next.js optimization (57 rules)
- **web-design-guidelines** - UI review against Web Interface Guidelines
- **skill-creator** - Guide for creating new skills

`npx skills add` installs to `~/.agents/skills/` and creates symlinks in `skills/`. Claude Code and Cursor both symlink to `skills/`, so both see the installed skills.

## Private Submodule

The `private/` directory is a git submodule pointing to a private repo (`dotfiles-private`). This holds sensitive or personal configs that shouldn't be in the public dotfiles repo.

**Structure:**
```
private/                           # Git submodule (private repo)
└── skills/                        # Personal skills
    └── tweet-caption/             # Tweet caption generator (trained on personal tweets)
```

**How it works:**
- Public dotfiles repo tracks the submodule reference (commit SHA) and symlinks
- Private repo holds the actual sensitive content
- Symlinks in `skills/` point to `private/skills/` (e.g., `skills/tweet-caption` → `../private/skills/tweet-caption`)
- Both public and private content work seamlessly via symlinks

**On new machines:**
```bash
git clone https://github.com/jamesvclements/dotfiles.git ~/.dotfiles
cd ~/.dotfiles
git submodule update --init --recursive  # Fetches private repo
./setup.sh
```

**Adding new private content:**
1. Add files to `private/` directory
2. Commit and push to private repo: `cd private && git add . && git commit -m "..." && git push`
3. Update main repo to track new commit: `cd ~/.dotfiles && git add private && git commit -m "..." && git push`

