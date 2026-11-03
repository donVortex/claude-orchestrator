#!/usr/bin/env bash
# SessionStart (startup, clear) hook: projects with knowledge default to the orchestrator.
. "$(dirname "$0")/lib.sh"

HOOK="$PWD/hooks/project-default.sh"

# with_knowledge <dir>: a git repo whose checkout has .claude/orchestrator/
with_knowledge() {
  mkdir -p "$1/.claude/orchestrator"
  git -C "$1" init -q -b main
  echo "<!-- budget: 150 lines -->" > "$1/.claude/orchestrator/domain.md"
}

run_hook() {
  out=$(cd "$1" && env -u ORCH_DEFAULT -u ORCH_ROLE "${@:2}" bash "$HOOK" 2>&1)
  code=$?
}

# no_knowledge: plain repo → silent
d=$(make_tmp); git -C "$d" init -q -b main; run_hook "$d"
assert_eq "" "$out" "no_knowledge: silent"
assert_eq 0 "$code" "no_knowledge: exit 0"

# not_a_repo → silent
run_hook "$(make_tmp)"
assert_eq "" "$out" "not_a_repo: silent"

# with_knowledge → the default-workflow note
d=$(make_tmp); with_knowledge "$d"; run_hook "$d"
assert_eq 0 "$code" "with_knowledge: exit 0"
assert_contains "$out" "[session-orchestrator]" "with_knowledge: tagged note"
assert_contains "$out" "session-orchestrator:orchestrating" "with_knowledge: names the skill"
assert_contains "$out" "session-orchestrator:working" "with_knowledge: tells workers to ignore it"

# opted_out: ORCH_DEFAULT=off → silent
d=$(make_tmp); with_knowledge "$d"; run_hook "$d" ORCH_DEFAULT=off
assert_eq "" "$out" "opted_out: silent"

# cli_worker: ORCH_ROLE=worker → silent
d=$(make_tmp); with_knowledge "$d"; run_hook "$d" ORCH_ROLE=worker
assert_eq "" "$out" "cli_worker: silent"

# subdirectory and path with space
d="$(make_tmp)/my repo"; mkdir -p "$d"; with_knowledge "$d"; mkdir -p "$d/src"; run_hook "$d/src"
assert_contains "$out" "session-orchestrator:orchestrating" "subdir_with_space: note"

# hooks.json wiring
hooks=$(cat hooks/hooks.json 2>/dev/null)
assert_contains "$hooks" '"startup"' "hooks_json: startup matcher"
assert_contains "$hooks" '"clear"' "hooks_json: clear matcher"
assert_contains "$hooks" 'project-default.sh' "hooks_json: runs project-default.sh"

finish
