#!/usr/bin/env bash
# Task ids keep counting across a project's orchestrations, so the user's
# session list never shows two sessions with the same T<n>.
. "$(dirname "$0")/lib.sh"

ledger=$(cat skills/orchestrating/references/ledger.md 2>/dev/null)
orch=$(cat skills/orchestrating/SKILL.md 2>/dev/null)

assert_contains "$ledger" "## Task ids" "ledger: task ids section"
assert_contains "$ledger" "one past the highest" "ledger: new run continues after the highest id"
assert_not_contains "$ledger" 'restart at `T1` for every orchestration' "ledger: ids no longer restart"
assert_contains "$ledger" "keeps its ids" "ledger: a resumed run keeps its numbers"
assert_contains "$orch" "references/ledger.md#task-ids" "intake: numbering rule linked"

# The snippet in "## Task ids" picks the next id from archived ledgers and orch/T* branches.
snippet=$(awk '/^## Task ids/{s=1} s&&/^```bash/{c=1;next} c&&/^```/{exit} c' skills/orchestrating/references/ledger.md)
[ -n "$snippet" ] || fail "ledger: task ids section has a bash snippet"

next_id() { (cd "$1" && root="$1" && eval "$snippet" && echo "$next"); }

repo() {
  d=$(make_tmp)
  git -C "$d" init -q -b main
  git -C "$d" -c user.email=t@t -c user.name=t commit -q --allow-empty -m init
  echo "$d"
}
archive() { # archive <repo> <name> <ids...>
  dir="$1/.orchestration/archive/$2"; mkdir -p "$dir"; shift 2
  { echo '| id | task | owns |'; echo '|----|------|------|'
    for id in "$@"; do echo "| $id | x | src/** |"; done; } > "$dir/ledger.md"
}

d=$(repo)
assert_eq 1 "$(next_id "$d")" "no archive, no branches: T1"

d=$(repo)
archive "$d" 2026-10-01-shop T1 T2 T3 T4 T5 T6 T7 T8
archive "$d" 2026-10-20-polish T1 T2 T3
assert_eq 9 "$(next_id "$d")" "two archives that each restarted: continue after T8"

d=$(repo)
archive "$d" 2026-10-01-a T1 T2
git -C "$d" branch orch/T11-search
git -C "$d" branch orch/knowledge-2026-10-01
assert_eq 12 "$(next_id "$d")" "a leftover orch/T11-* branch counts, knowledge branches don't"

d=$(repo)
archive "$d" 2026-10-01-a T9 T10
assert_eq 11 "$(next_id "$d")" "numeric order, not text order (T10 > T9)"

finish
