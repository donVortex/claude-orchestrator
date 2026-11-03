#!/usr/bin/env bash
# SessionStart hook (compact, resume): re-injects an active orchestration ledger into context.
# Silent with exit 0 when there is no ledger or it is done, so it never breaks a session start.
# Usage: ledger-context.sh [project-dir]   (default: $CLAUDE_PROJECT_DIR, then $PWD)

MAX_LINES=150

dir="${1:-${CLAUDE_PROJECT_DIR:-$PWD}}"
# State lives in the main checkout, even when this session runs in a worktree.
if common=$(git -C "$dir" rev-parse --path-format=absolute --git-common-dir 2>/dev/null); then
  dir=$(dirname "$common")
fi
ledger="$dir/.orchestration/ledger.md"

[ -r "$ledger" ] || exit 0
content=$(tr -d '\r' < "$ledger" 2>/dev/null) || exit 0
printf '%s\n' "$content" | head -n 5 | grep -q 'Status: done' && exit 0

total=$(printf '%s\n' "$content" | wc -l)

echo "[session-orchestrator] An orchestration is in progress. Ledger (.orchestration/ledger.md):"
printf '%s\n' "$content" | head -n "$MAX_LINES"
if [ "$total" -gt "$MAX_LINES" ]; then
  echo "... (truncated — read .orchestration/ledger.md for the rest)"
fi
echo "Continue with the session-orchestrator:orchestrating skill. The ledger is the source of truth."
exit 0
