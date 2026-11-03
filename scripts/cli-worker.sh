#!/usr/bin/env bash
# CLI backend for session-orchestrator: runs a worker as headless `claude -p` in its own worktree.
#   cli-worker.sh start  <task-id> <base-branch> <model> <effort> <brief-file>
#   cli-worker.sh resume <task-id> <session-id> <message-file>
#   cli-worker.sh remove <task-id>
# Run from anywhere inside the main checkout. Worktree: <repo-root>-wt/<task-id>, branch orch/<task-id>.
# Stdout is claude's JSON result (with session_id); progress goes to stderr.
# Exit: 1 git failure, 2 usage or invalid id, 3 base branch not found,
#       4 directory exists but is not this task's worktree, 5 no worktree (resume/remove);
#       otherwise claude's exit code.
# Env: CLAUDE_BIN (default: claude), ORCH_ALLOWLIST (default: ../settings/worker-allowlist.json).

script_dir=$(cd "$(dirname "$0")" && pwd)
CLAUDE_BIN="${CLAUDE_BIN:-claude}"
ORCH_ALLOWLIST="${ORCH_ALLOWLIST:-$script_dir/../settings/worker-allowlist.json}"

die() {
  echo "cli-worker: $2" >&2
  exit "$1"
}

usage() {
  sed -n '3,5p' "$0" | sed 's/^# //' >&2
  exit 2
}

# Sets root (main checkout), dir (task worktree) and branch for a task id.
locate() {
  printf '%s' "$1" | grep -Eq '^[A-Za-z0-9][A-Za-z0-9_-]*$' || die 2 "invalid task id: $1"
  common=$(git rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || die 2 "not inside a git repository"
  root=$(dirname "$common")
  dir="$root-wt/$1"
  branch="orch/$1"
}

is_task_worktree() {
  [ -d "$dir" ] && [ "$(git -C "$dir" rev-parse --abbrev-ref HEAD 2>/dev/null)" = "$branch" ]
}

run_claude() {
  cd "$dir" || die 1 "cannot enter $dir"
  exec "$CLAUDE_BIN" "$@" --output-format json --permission-mode acceptEdits --settings "$ORCH_ALLOWLIST"
}

cmd_start() {
  [ $# -eq 5 ] || usage
  locate "$1"
  base=$2 model=$3 effort=$4
  [ -r "$5" ] || die 2 "brief file not readable: $5"
  prompt=$(cat "$5")

  if [ -e "$dir" ]; then
    is_task_worktree || die 4 "$dir exists but is not the worktree for $branch"
    echo "cli-worker: reusing $dir" >&2
  elif git -C "$root" show-ref --verify --quiet "refs/heads/$branch"; then
    git -C "$root" worktree add "$dir" "$branch" >&2 || die 1 "git worktree add failed"
  else
    git -C "$root" rev-parse --verify --quiet "$base^{commit}" >/dev/null || die 3 "base branch not found: $base"
    git -C "$root" worktree add -b "$branch" "$dir" "$base" >&2 || die 1 "git worktree add failed"
  fi

  run_claude -p "$prompt" --model "$model" --effort "$effort"
}

cmd_resume() {
  [ $# -eq 3 ] || usage
  locate "$1"
  [ -r "$3" ] || die 2 "message file not readable: $3"
  message=$(cat "$3")
  is_task_worktree || die 5 "no worktree for $1 at $dir"
  run_claude -p "$message" --resume "$2"
}

cmd_remove() {
  [ $# -eq 1 ] || usage
  locate "$1"
  is_task_worktree || die 5 "no worktree for $1 at $dir"
  git -C "$root" worktree remove "$dir" >&2 || die 1 "git worktree remove failed (uncommitted changes in $dir?)"
}

command=${1:-}
[ $# -gt 0 ] && shift
case "$command" in
  start) cmd_start "$@" ;;
  resume) cmd_resume "$@" ;;
  remove) cmd_remove "$@" ;;
  *) usage ;;
esac
