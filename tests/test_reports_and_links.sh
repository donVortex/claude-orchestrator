#!/usr/bin/env bash
# Desktop workers report through the app's shared notes folder; linked
# dependencies in worktrees are unlinked, never installed through or deleted recursively.
. "$(dirname "$0")/lib.sh"

desktop=$(cat skills/orchestrating/references/backend-desktop.md 2>/dev/null)
brief=$(cat skills/orchestrating/references/brief-template.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)
worker=$(cat skills/working/SKILL.md 2>/dev/null)
format=$(cat skills/working/report-format.md 2>/dev/null)
knowledge=$(cat skills/orchestrating/references/knowledge.md 2>/dev/null)
ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)

# P1: report path on the desktop backend
assert_contains "$desktop" "shared notes folder" "desktop: reports go to the shared notes folder"
assert_contains "$desktop" "blocks workers from writing outside their worktree" "desktop: says why the main checkout fails"
assert_contains "$desktop" 'copy it to `$root/.orchestration/reports/T<n>.md`' "desktop: orchestrator copies the report into reports/"
assert_not_contains "$desktop" "Workers write their report to the main checkout" "desktop: no main-checkout report path"
assert_contains "$brief" 'CLI mode: `<$root>/.orchestration/reports/T<n>.md`' "brief: CLI report path stays in the main checkout"
assert_contains "$brief" 'Desktop: `<notes>/T<n>-report.md`' "brief: desktop report path in the notes folder"
assert_not_contains "$brief" "points at the **main** checkout |" "brief check: no main-checkout-only rule"
assert_contains "$orch" "copy it there from the shared notes folder first" "orchestrating: reads desktop reports via the copy"
assert_contains "$worker" "shared notes folder your session instructions name" "worker: knows which notes folder"
assert_contains "$format" "shared notes folder in desktop mode" "report format: desktop path"
assert_contains "$ledger" "CLI briefs' report paths" "ledger: \$root report paths are for CLI briefs"

# P2: linked dependencies in worktrees
assert_contains "$knowledge" "## Linked dependencies" "knowledge: linked dependencies section"
assert_contains "$knowledge" 'cmd //c rmdir' "knowledge: unlink a Windows junction with rmdir"
assert_contains "$knowledge" "never run an install" "knowledge: no install through the link"
assert_contains "$knowledge" 'never `rm -r`' "knowledge: no recursive delete of the link"
assert_contains "$orch" "remove the link first" "review step: unlink before worktree remove"
assert_contains "$orch" "references/knowledge.md#linked-dependencies" "review step links the rule"
assert_contains "$worker" "never run an install" "worker: no install through linked dependencies"

finish
