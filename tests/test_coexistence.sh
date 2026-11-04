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

finish
