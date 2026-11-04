#!/usr/bin/env bash
# SessionStart hook: development mode only in the plugin's own checkout (.plugin-dev marker); standalone everywhere else.
. "$(dirname "$0")/lib.sh"

HOOK="$PWD/hooks/plugin-mode.sh"
LINE='[session-orchestrator] development mode'

# run_hook <plugin-root> [env assignments...]
run_hook() {
  root=$1; shift
  out=$(env -u ORCH_PLUGIN_MODE -u EVAL_ORCH_PLUGIN_MODE CLAUDE_PLUGIN_ROOT="$root" "$@" bash "$HOOK" 2>&1)
  code=$?
}

# marker present → development mode line
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d"
assert_eq 0 "$code" "marker: exit 0"
assert_contains "$out" "$LINE" "marker: development mode line"

# no marker (a GitHub install) → silent
d=$(make_tmp); run_hook "$d"
assert_eq "" "$out" "no_marker: silent (standalone)"

# override for testing → silent even with the marker
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d" ORCH_PLUGIN_MODE=standalone
assert_eq "" "$out" "override: silent (standalone)"

# eval form of the override
d=$(make_tmp); touch "$d/.plugin-dev"; run_hook "$d" EVAL_ORCH_PLUGIN_MODE=standalone
assert_eq "" "$out" "eval_override: silent (standalone)"

# path with a space
d="$(make_tmp)/my plugin"; mkdir -p "$d"; touch "$d/.plugin-dev"; run_hook "$d"
assert_contains "$out" "$LINE" "space: development mode line"

# wired into every SessionStart matcher
hooks=$(cat hooks/hooks.json)
n=$(grep -c 'plugin-mode.sh' hooks/hooks.json)
assert_eq 4 "$n" "hooks_json: plugin-mode.sh on startup, clear, compact and resume"

# the marker never reaches GitHub
assert_contains "$(cat .gitignore)" ".plugin-dev" "gitignore lists .plugin-dev"
assert_eq "" "$(git ls-files .plugin-dev)" ".plugin-dev is not tracked"

finish
