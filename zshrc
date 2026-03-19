# Homebrew
eval "$(/opt/homebrew/bin/brew shellenv)"

# Obsidian CLI (bundled with Obsidian.app)
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"


# fnm
export PATH="$HOME/Library/Application Support/fnm:$PATH"
eval "`fnm env`"
corepack enable

# aliases
alias reset='find . -maxdepth 1 \( -name node_modules -prune \) -o -maxdepth 2 \( -name node_modules -o -name .next -type d -o -name .pnpm-lock.yaml -type f \) -print0 | xargs -0 rm -rf'

# git shortcut
g() {
  git "$@"
}

# restore file from main
restore() {
  git checkout "origin/main" -- "$1"
}

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$HOME/bin:$PATH"

# Spaceship prompt
[[ -f ~/.spaceshiprc.zsh ]] && source ~/.spaceshiprc.zsh
source /opt/homebrew/opt/spaceship/spaceship.zsh

# Machine-specific config (secrets, local overrides)
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
export PATH="$HOME/.local/bin:$PATH"

# Added by Hades
export PATH="$PATH:$HOME/.hades/bin"
