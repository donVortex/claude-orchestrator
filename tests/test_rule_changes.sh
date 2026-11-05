#!/usr/bin/env bash
# Rules change as the product does: a goal that changes a rule is confirmed on
# the plan, briefs quote only the new rule, the wrap-up edits the entry in place,
# and entries naming paths or functions that no longer exist are flagged as stale.
. "$(dirname "$0")/lib.sh"

knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
learning=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)

# Rule changes
assert_contains "$knowledge" "## Rule changes" "knowledge: rule changes section"
assert_contains "$knowledge" 'Changes rule: <old entry> → <new rule>' "knowledge: plan line for a changed rule"
assert_contains "$knowledge" "Never add a second entry beside the old one" "knowledge: edit in place, no second entry"
assert_contains "$knowledge" "git history" "knowledge: old versions live in git, not in the files"
assert_contains "$knowledge" "One rule, one place" "knowledge: no duplicate rules"
assert_contains "$knowledge" "ask; don't guess" "knowledge: unclear change → ask"
assert_contains "$orch" 'Changes rule: <old entry> → <new rule>' "approval gate shows changed rules"
assert_contains "$orch" "references/knowledge.md#rule-changes" "intake links the rule-change rules"
assert_contains "$learning" '[event] rule change: <old> → <new>' "ledger line for a rule change"
assert_contains "$brief" "only the new version of a rule the goal changes" "brief: only the new rule is quoted"

# Stale entries
assert_contains "$knowledge" "## Stale entries" "knowledge: stale entries section"
assert_contains "$knowledge" 'git cat-file -e' "knowledge: path check against the base branch"
assert_contains "$knowledge" 'git grep -q' "knowledge: name check against the base branch"
assert_contains "$learning" '[event] stale entry:' "ledger line for a stale entry"
assert_contains "$orch" "references/knowledge.md#stale-entries" "intake links the stale-entry check"
assert_contains "$brief" "never a stale one" "brief: stale entries are not quoted"

# Wrap-up diff picks both up
assert_contains "$knowledge" 'plus the `rule change` and `stale entry` events' "diff: candidates include rule changes and stale entries"
assert_contains "$knowledge" "shown as old → new" "diff: edits shown old → new"

finish
