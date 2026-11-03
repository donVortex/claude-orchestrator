#!/usr/bin/env bash
# Role agents' frontmatter and the model tier rubric's machine-checked lines.
. "$(dirname "$0")/lib.sh"

# Prints the value of a frontmatter field from an agent file.
field() {
  tr -d '\r' < "$1" 2>/dev/null | awk 'NR==1 && /^---$/ {f=1; next} f && /^---$/ {exit} f' |
    grep -m1 "^$2:" | sed "s/^$2:[[:space:]]*//"
}

check_agent() {
  f="agents/$1.md"
  assert_file "$f" "$1 agent exists"
  assert_eq "$1" "$(field "$f" name)" "$1 name matches filename"
  [ -n "$(field "$f" description)" ] || fail "$1 has a description"
  assert_eq "$2" "$(field "$f" model)" "$1 default model"
}

check_agent orch-scout haiku
check_agent orch-implementer sonnet
check_agent orch-specialist opus

scout_tools=$(field agents/orch-scout.md tools)
[ -n "$scout_tools" ] || fail "orch-scout declares tools"
assert_not_contains "$scout_tools" "Edit" "orch-scout is read-only (no Edit)"
assert_not_contains "$scout_tools" "Write" "orch-scout is read-only (no Write)"

tiers=$(cat skills/orchestrating/references/model-tiers.md 2>/dev/null)
assert_contains "$tiers" '| `fast` | haiku | sonnet / low |' "fast tier row"
assert_contains "$tiers" '| `standard` | sonnet | sonnet / medium |' "standard tier row"
assert_contains "$tiers" '| `deep` | opus | opus / high |' "deep tier row"
assert_contains "$tiers" 'max_parallel_workers: 4' "worker cap"
assert_contains "$tiers" 'max_parallel_implementers_per_session: 3' "implementer cap"

finish
