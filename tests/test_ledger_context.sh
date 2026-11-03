#!/usr/bin/env bash
# SessionStart hook: re-injects an active orchestration ledger, silent otherwise.
. "$(dirname "$0")/lib.sh"

HOOK="$PWD/hooks/ledger-context.sh"
INTRO='[session-orchestrator] An orchestration is in progress. Ledger (.orchestration/ledger.md):'
OUTRO='Continue with the session-orchestrator:orchestrating skill. The ledger is the source of truth.'

# write_ledger <project-dir> <status>
write_ledger() {
  mkdir -p "$1/.orchestration"
  cat > "$1/.orchestration/ledger.md" <<EOF
# Orchestration: add login
Started: 2026-11-03 · Backend: desktop · Base branch: main · Status: $2

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T1 | schema | src/db/schema.ts | — | deep | self | — | orch/T1 | #12 | merged |
| T2 | api | src/api/users/** | T1 | standard | worker | local_ab12 | orch/T2 | #13 | in-review |
EOF
}

run_hook() {
  out=$(bash "$HOOK" "$1" 2>&1)
  code=$?
}

# no_ledger
d=$(make_tmp); run_hook "$d"
assert_eq "" "$out" "no_ledger: silent"
assert_eq 0 "$code" "no_ledger: exit 0"

# not_a_repo
run_hook "$(make_tmp)/does-not-exist"
assert_eq "" "$out" "not_a_repo: silent"
assert_eq 0 "$code" "not_a_repo: exit 0"

# done_ledger
d=$(make_tmp); write_ledger "$d" done; run_hook "$d"
assert_eq "" "$out" "done_ledger: silent"
assert_eq 0 "$code" "done_ledger: exit 0"

# running_ledger
d=$(make_tmp); write_ledger "$d" running; run_hook "$d"
assert_eq 0 "$code" "running_ledger: exit 0"
assert_contains "$out" "$INTRO" "running_ledger: intro line"
assert_contains "$out" "# Orchestration: add login" "running_ledger: goal line"
assert_contains "$out" "| T2 |" "running_ledger: task row"
assert_contains "$out" "$OUTRO" "running_ledger: closing line"

# crlf_ledger
d=$(make_tmp); write_ledger "$d" running
sed -i 's/$/\r/' "$d/.orchestration/ledger.md"
run_hook "$d"
assert_contains "$out" "| T2 |" "crlf_ledger: task row"
assert_not_contains "$out" $'\r' "crlf_ledger: no carriage returns"

# long_ledger
d=$(make_tmp); write_ledger "$d" running
i=1; while [ $i -le 300 ]; do echo "- event line $i" >> "$d/.orchestration/ledger.md"; i=$((i + 1)); done
run_hook "$d"
assert_contains "$out" "... (truncated — read .orchestration/ledger.md for the rest)" "long_ledger: truncation note"
assert_not_contains "$out" "event line 200" "long_ledger: line 200 cut"
assert_contains "$out" "$OUTRO" "long_ledger: closing line"

# path_with_space
d="$(make_tmp)/my repo"; mkdir -p "$d"; write_ledger "$d" running; run_hook "$d"
assert_contains "$out" "$INTRO" "path_with_space: intro line"
assert_contains "$out" "| T2 |" "path_with_space: task row"

# defaults to CLAUDE_PROJECT_DIR
d=$(make_tmp); write_ledger "$d" running
out=$(CLAUDE_PROJECT_DIR="$d" bash "$HOOK" 2>&1)
assert_contains "$out" "| T2 |" "project_dir_env: reads CLAUDE_PROJECT_DIR"

# worktree_session: ledger lives in the main checkout, session runs in a worktree
d=$(make_tmp)/repo; mkdir -p "$d"
git -C "$d" init -q -b main
git -C "$d" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
write_ledger "$d" running
git -C "$d" worktree add -q -b wt "$d-wt" 2>/dev/null
run_hook "$d-wt"
assert_contains "$out" "| T2 |" "worktree_session: finds the main checkout's ledger"

# hooks_json
hooks=$(cat hooks/hooks.json 2>/dev/null)
assert_contains "$hooks" '"compact"' "hooks_json: compact matcher"
assert_contains "$hooks" '"resume"' "hooks_json: resume matcher"
assert_contains "$hooks" 'ledger-context.sh' "hooks_json: runs the script"
assert_contains "$hooks" '${CLAUDE_PLUGIN_ROOT}' "hooks_json: plugin-root path"
if command -v node >/dev/null 2>&1; then
  node -e "JSON.parse(require('fs').readFileSync('hooks/hooks.json','utf8'))" 2>/dev/null || fail "hooks_json: valid JSON"
fi

finish
