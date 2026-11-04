#!/usr/bin/env bash
# Superpowers precedence: the orchestrator owns plan and execution; workers skip the steps a brief replaces.
. "$(dirname "$0")/lib.sh"

orch=$(cat skills/orchestrating/SKILL.md)
assert_contains "$orch" "## Alongside superpowers" "orchestrating: has a superpowers section"
assert_contains "$orch" "superpowers:brainstorming" "orchestrating: brainstorming allowed for an unclear goal"
assert_contains "$orch" "instead of superpowers:writing-plans" "orchestrating: breakdown replaces writing-plans"

work=$(cat skills/working/SKILL.md)
assert_contains "$work" "**Alongside superpowers.**" "working: has a superpowers paragraph"
for s in brainstorming writing-plans using-git-worktrees finishing-a-development-branch; do
  assert_contains "$work" "superpowers:$s" "working: names $s"
done
assert_contains "$work" "never merge" "working: never merges"

hook=$(cat hooks/project-default.sh)
assert_contains "$hook" "superpowers" "project-default note covers superpowers"

finish
