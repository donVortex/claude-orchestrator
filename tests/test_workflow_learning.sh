#!/usr/bin/env bash
# Workflow-learning reference: event kinds, counts table, plan labels, headings; ledger uses the tags.
. "$(dirname "$0")/lib.sh"

ref=$(cat skills/orchestrating/references/workflow-learning.md 2>/dev/null)
assert_file skills/orchestrating/references/workflow-learning.md "workflow-learning.md exists"

for tag in '[ask-user]' '[approval]' '[prompt]' '[start-click]' '[failed]' '[changes]' '[escalate]' '[worker-q]' '[event]'; do
  assert_contains "$ref" "$tag" "event kind $tag"
done

assert_contains "$ref" "| task | recipe | ask-user | approval | prompt | start-click | failed | changes | escalate | worker-q |" "counts table header"
assert_contains "$ref" "Assumed from project knowledge:" "plan label for learned defaults"
assert_contains "$ref" "Following recipe:" "plan label for recipes"

for h in "## Event kinds" "## Counts table" "## Findings to proposals" "## Using what was learned" "## Guardrails"; do
  assert_contains "$ref" "$h" "heading [$h]"
done

assert_contains "$ref" '[env]' "event kind [env] for environment-lost rounds"
for prefix in '[event] pre-flight:' 'following recipe:' '[event] assumed default:' '[event] user overrode default:'; do
  assert_contains "$ref" "$prefix" "fixed-prefix event line [$prefix]"
done
assert_contains "$ref" ".orchestration/counts.md" "full counts table goes to a file"
assert_contains "$ref" "Don't propose what's already there" "dedupe rule"
assert_contains "$(cat skills/orchestrating/references/knowledge.md)" 'except calibration'"'"'s `## Recipes`' "bootstrap keeps the workflow sections"

ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
assert_contains "$ledger" "[ask-user]" "ledger.md shows a tagged event"
assert_contains "$ledger" "starts with a kind tag" "ledger.md requires kind tags"

finish
