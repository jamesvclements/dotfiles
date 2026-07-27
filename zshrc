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

# given a Vercel deployment/preview URL, print its status + deployment + PR links.
# auto-detects which team the deployment belongs to (no scope needed): it tries
# your personal scope, then fans out parallel API calls across all your teams.
# talks to the Vercel REST API directly with the CLI's stored token (curl, not
# the node CLI) so the whole-team search stays ~1s instead of a process per team.
# a deployment's team never changes, so the host->team match is cached: repeat
# lookups skip the fan-out (one direct call) but still fetch live status.
# usage: gimme <url> [team]     # team (slug or id) is an optional fast-path override
gimme() {
  setopt localoptions null_glob no_monitor  # empty globs vanish; no "[1] <pid>" job spam
  local url="$1" only="$2"
  if [[ -z "$url" ]]; then
    echo "usage: gimme <vercel-deployment-url> [team]" >&2
    return 1
  fi

  local host="${url#*://}"
  host="${host%%/*}"
  host="${host%%\?*}"

  # locate the CLI's stored token (macOS path first, then XDG fallbacks)
  local authfile tok
  for authfile in \
    "$HOME/Library/Application Support/com.vercel.cli/auth.json" \
    "${XDG_DATA_HOME:-$HOME/.local/share}/com.vercel.cli/auth.json" \
    "$HOME/.config/com.vercel.cli/auth.json"; do
    [[ -f "$authfile" ]] && break
  done
  tok=$(jq -r '.token // empty' "$authfile" 2>/dev/null)
  if [[ -z "$tok" ]]; then
    echo "gimme: no Vercel token found — run 'vercel login'" >&2
    return 1
  fi

  local api="https://api.vercel.com"
  local dpath="/v13/deployments/${host}"
  local jqhit='.id and (.error|not)'          # a body is a real deployment
  local cache="${XDG_CACHE_HOME:-$HOME/.cache}/gimme/host-team.tsv"
  local resp="" tid=""                          # tid: "-" = personal, else a team id

  # fetch host under a given scope ("-" = personal); echoes body iff it's a real hit
  _gimme_fetch() {
    local q="" body
    [[ "$1" != "-" ]] && q="?teamId=$1"
    body=$(curl -s -H "Authorization: Bearer $tok" "${api}${dpath}${q}" | tr -d '\000-\037')
    jq -e "$jqhit" >/dev/null 2>&1 <<< "$body" && printf '%s' "$body"
  }

  if [[ -n "$only" ]]; then
    # explicit team: resolve slug-or-id to a team id, then one call
    tid=$(curl -s -H "Authorization: Bearer $tok" "${api}/v2/teams?limit=100" \
      | tr -d '\000-\037' \
      | jq -r --arg t "$only" '.teams[] | select(.slug==$t or .id==$t) | .id' | head -1)
    if [[ -z "$tid" ]]; then
      echo "gimme: no team matching '$only'" >&2
      unfunction _gimme_fetch
      return 1
    fi
    resp=$(_gimme_fetch "$tid")
  else
    # 1) cached team for this host -> one direct call (still live status)
    if [[ -f "$cache" ]]; then
      local cached
      cached=$(awk -F'\t' -v h="$host" '$1==h{print $2; exit}' "$cache")
      if [[ -n "$cached" ]]; then
        resp=$(_gimme_fetch "$cached") && tid="$cached"
      fi
    fi
    # 2) personal scope
    if [[ -z "$resp" ]]; then
      resp=$(_gimme_fetch "-") && tid="-"
    fi
    # 3) fan out across every team in parallel, first real hit wins
    if [[ -z "$resp" ]]; then
      local ids id tmpd
      ids=$(curl -s -H "Authorization: Bearer $tok" "${api}/v2/teams?limit=100" \
        | tr -d '\000-\037' | jq -r '.teams[].id')
      tmpd=$(mktemp -d)
      for id in ${(f)ids}; do
        (
          local body; body=$(_gimme_fetch "$id")
          [[ -n "$body" ]] && printf '%s' "$body" > "$tmpd/hit.$id"
        ) &
      done
      wait
      local -a hits=( "$tmpd"/hit.* )   # only the matching team wrote a file
      if (( ${#hits} )); then
        resp=$(<"${hits[1]}")
        tid="${hits[1]##*/hit.}"
      fi
      rm -rf "$tmpd"
    fi
  fi

  unfunction _gimme_fetch

  if [[ -z "$resp" ]]; then
    # distinguish an expired token from a genuine miss
    local code
    code=$(curl -s -o /dev/null -w '%{http_code}' -H "Authorization: Bearer $tok" "${api}/v2/user")
    if [[ "$code" == "401" || "$code" == "403" ]]; then
      echo "gimme: Vercel token expired — run any 'vercel' command (e.g. 'vercel whoami') to refresh, then retry" >&2
    else
      echo "gimme: no deployment found for '$host' in your personal scope or any of your teams" >&2
    fi
    return 1
  fi

  # remember which team this host lives under, so next time skips the fan-out
  if [[ -n "$tid" ]]; then
    mkdir -p "${cache:h}"
    local tmpc; tmpc=$(mktemp)
    { [[ -f "$cache" ]] && awk -F'\t' -v h="$host" '$1!=h' "$cache"; printf '%s\t%s\n' "$host" "$tid"; } > "$tmpc"
    mv "$tmpc" "$cache"
  fi

  # pull every field in one jq pass ('|'-joined; not whitespace, so empty
  # fields keep their position when split back out)
  local deployment inspector state target org repo pr_id
  IFS='|' read -r deployment inspector state target org repo pr_id <<< "$(
    jq -r '[ (.url // ""),
             (.inspectorUrl // ""),
             (.readyState // .state // ""),
             (.target // ""),
             (.meta.githubOrg // .meta.githubCommitOrg // ""),
             (.meta.githubRepo // .meta.githubCommitRepo // ""),
             (.meta.githubPrId // "") ] | join("|")' <<< "$resp"
  )"

  local st="$state"
  [[ -n "$target" ]] && st+=" ($target)"
  [[ -n "$st" ]]            && echo "Status:      $st"
  [[ -n "$deployment" ]]    && echo "Deployment:  https://${deployment}"
  [[ -n "$inspector" ]]     && echo "Dashboard:   $inspector"
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
