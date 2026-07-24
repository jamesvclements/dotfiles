#!/usr/bin/env bash
# PreToolUse(Bash) hook: auto-allow `git push` to NON-default branches; let pushes
# to the default branch (main/master) — and anything ambiguous — fall through to
# the normal permission flow (the `ask` rule prompts). Errs toward prompting.
#
# Output contract: print a PreToolUse "allow" decision ONLY for a clearly-safe
# non-default push. For everything else, exit 0 with no output (no decision).

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)
[ -n "$cmd" ] || exit 0

# Must be a git push command.
printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])git[[:space:]]+push([[:space:]]|$)' || exit 0

# Only auto-allow a single, simple push. Bail (→ prompt) on compound/expanded
# commands so we never misjudge something like `... && git push origin main`.
case "$cmd" in
  *"&&"*|*"||"*|*";"*|*"|"*|*'`'*|*'$('*) exit 0 ;;
esac

# Bail on whole-repo / multi-branch pushes that can include the default branch.
printf '%s' "$cmd" | grep -Eq '(^|[[:space:]])(--all|--mirror|--prune)([[:space:]]|=|$)' && exit 0

protected='^(main|master)$'
cur=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Tokenize and collect refspecs (the non-flag args after the remote).
read -r -a toks <<< "$cmd"
seen_push=0 remote_seen=0 skip_next=0
refspecs=()
for t in "${toks[@]}"; do
  if [ "$skip_next" = 1 ]; then skip_next=0; continue; fi
  if [ "$seen_push" = 0 ]; then [ "$t" = "push" ] && seen_push=1; continue; fi
  case "$t" in
    -o|--push-option|--repo|--exec|--receive-pack) skip_next=1; continue ;;
    -*) continue ;;
    *)
      if [ "$remote_seen" = 0 ]; then remote_seen=1; continue; fi
      refspecs+=("$t") ;;
  esac
done

allow() {
  printf '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"allow","permissionDecisionReason":%s}}\n' \
    "$(printf '%s' "$1" | jq -R -s '.')"
  exit 0
}

# No explicit refspec → git pushes the current branch.
if [ "${#refspecs[@]}" -eq 0 ]; then
  [ -z "$cur" ] && exit 0
  printf '%s' "$cur" | grep -Eq "$protected" && exit 0
  allow "push of current branch '$cur' (non-default)"
fi

# Every destination must be a non-default branch, or we bail to a prompt.
for r in "${refspecs[@]}"; do
  d="${r#+}"                 # strip leading + (force refspec)
  [ "$d" = "HEAD" ] && d="$cur"
  case "$d" in *:*) d="${d##*:}" ;; esac   # remote side of src:dst
  [ "$d" = "HEAD" ] && d="$cur"
  [ -z "$d" ] && exit 0
  printf '%s' "$d" | grep -Eq "$protected" && exit 0
done
allow "push to non-default branch(es): ${refspecs[*]}"
