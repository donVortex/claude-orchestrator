#!/usr/bin/env bash
# Coexistence with other skills and plugins: one contract, judged by effect; skills in briefs; learning per project.
. "$(dirname "$0")/lib.sh"

# the contract reference
c=$(cat skills/orchestrating/references/coexistence.md 2>/dev/null)
assert_file skills/orchestrating/references/coexistence.md "coexistence.md exists"
for h in "## Who owns what" "## Rules by effect" "## Tie-breaker" "## Intake, plan and briefs" "## Reviews" "## Example: superpowers"; do
  assert_contains "$c" "$h" "coexistence: heading [$h]"
done
assert_contains "$c" "| Merging | the user |" "coexistence: user merges"
assert_contains "$c" "who decides" "coexistence: tie-breaker names who decides"
assert_contains "$c" "where code lands" "coexistence: tie-breaker names where code lands"
assert_contains "$c" "what ships" "coexistence: tie-breaker names what ships"
assert_contains "$c" "[event] skills: overlap" "coexistence: skills event prefix"
assert_contains "$c" "Other workflow skills:" "coexistence: plan line"
assert_contains "$c" "- Skills:" "coexistence: brief field"

# inline must-never-miss lines and the default note
orch=$(cat skills/orchestrating/SKILL.md); work=$(cat skills/working/SKILL.md); hook=$(cat hooks/project-default.sh)
assert_contains "$orch" "## Other skills and plugins" "orchestrating: section"
assert_contains "$orch" "references/coexistence.md" "orchestrating: links the contract"
assert_contains "$orch" "feed the breakdown, never replace it" "orchestrating: planners feed the breakdown"
assert_not_contains "$orch" "## Alongside superpowers" "orchestrating: superpowers section replaced"
assert_contains "$work" "**Other skills and plugins.**" "working: paragraph"
assert_contains "$work" "../orchestrating/references/coexistence.md" "working: links the contract"
for s in "never merge" "never create a worktree" "into the report" "never go into the PR" "the brief is the approved plan"; do
  assert_contains "$work" "$s" "working: [$s]"
done
assert_contains "$hook" "- Other skills and plugins" "hook: generalised line"
for e in orch-default-feature orch-default-question orch-superpowers-feature; do
  assert_contains "$(cat evals/$e/prompt.md)" "- Other skills and plugins" "eval $e copies the current hook line"
done

finish
