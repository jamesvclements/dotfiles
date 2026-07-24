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

# given a Vercel deployment/preview URL, print its inspector + PR links
# usage: gimme <url> [team-scope]
gimme() {
  local url="$1" scope="$2"
  if [[ -z "$url" ]]; then
    echo "usage: gimme <vercel-deployment-url> [team-scope]" >&2
    return 1
  fi

  local host="${url#*://}"
  host="${host%%/*}"
  host="${host%%\?*}"

  local -a scope_args
  [[ -n "$scope" ]] && scope_args=(--scope "$scope")

  local resp err rc
  err=$(mktemp)
  resp=$(vercel api "/v13/deployments/${host}" "${scope_args[@]}" 2>"$err")
  rc=$?
  local errmsg
  errmsg=$(<"$err")
  rm -f "$err"
  if [[ $rc -ne 0 ]]; then
    echo "gimme: couldn't look up '$host'" >&2
    [[ -n "$errmsg" ]] && echo "$errmsg" >&2
    return 1
  fi
  if ! jq -e . >/dev/null 2>&1 <<< "$resp"; then
    echo "gimme: unexpected response for '$host'" >&2
    echo "$resp" >&2
    return 1
  fi
  if jq -e '.error' >/dev/null 2>&1 <<< "$resp"; then
    echo "gimme: $(jq -r '.error.message // .error.code' <<< "$resp")" >&2
    return 1
  fi

  local deployment inspector state target branch branch_alias org repo pr_id
  deployment=$(jq -r '.url // empty' <<< "$resp")
  inspector=$(jq -r '.inspectorUrl // empty' <<< "$resp")
  state=$(jq -r '.readyState // .state // empty' <<< "$resp")
  target=$(jq -r '.target // empty' <<< "$resp")
  branch=$(jq -r '.meta.githubCommitRef // empty' <<< "$resp")
  branch_alias=$(jq -r '.meta.branchAlias // empty' <<< "$resp")
  org=$(jq -r '.meta.githubOrg // .meta.githubCommitOrg // empty' <<< "$resp")
  repo=$(jq -r '.meta.githubRepo // .meta.githubCommitRepo // empty' <<< "$resp")
  pr_id=$(jq -r '.meta.githubPrId // empty' <<< "$resp")

  local suffix=""
  if [[ -n "$state" ]]; then
    suffix=" ($state"
    [[ -n "$target" ]] && suffix+=", $target"
    suffix+=")"
  fi

  echo "Deployment:  https://${deployment}${suffix}"
  [[ -n "$inspector" ]] && echo "Inspector:   $inspector"
  [[ -n "$branch" ]] && echo "Branch:      $branch"
  [[ -n "$branch_alias" ]] && echo "Branch URL:  https://${branch_alias}"

  if [[ -n "$org" && -n "$repo" && -n "$pr_id" ]]; then
    echo "PR:          https://github.com/${org}/${repo}/pull/${pr_id}"
  else
    echo "PR:          none found (no open PR, or this is a main/production deploy)"
  fi
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

export PATH="$HOME/.local/bin:$PATH"

# Added by Hades
export PATH="$PATH:$HOME/.hades/bin"

# BEGIN: socket firewall aliases (managed by Iru)
alias npm="sfw npm"
alias pnpm="sfw pnpm"
alias bun="sfw bun"
# END: socket firewall aliases (managed by Iru)

# Machine-specific config (secrets, local overrides) — sourced last so it can override anything above
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
