#!/usr/bin/env bash
# Project knowledge templates: budget headers, section headings, no entries; wiring into briefs and reports.
. "$(dirname "$0")/lib.sh"

T=skills/orchestrating/references/knowledge-templates

# check_template <file> <budget> <heading>...
check_template() {
  name=$1; f="$T/$1"; budget=$2; shift 2
  assert_file "$f" "$name exists"
  [ -f "$f" ] || return
  assert_eq "<!-- budget: $budget lines -->" "$(head -n 1 "$f" | tr -d '\r')" "$(basename "$f") budget header"
  body=$(cat "$f")
  for h in "$@"; do
    assert_contains "$body" "$h" "$(basename "$f") has heading [$h]"
  done
  # Example entries inside <!-- --> comments are allowed; real entries are not.
  awk '/<!--/{c=1} !c{print} /-->/{c=0}' "$f" | grep -q '^- \*\*' && fail "$(basename "$f") has no entries (template only)"
}

check_template domain.md 150 "## Rules" "## Glossary"
check_template map.md 100 "## Areas" "## Feature flows"
check_template review-checklist.md 60 "## Always check" "## When touching <area>"
check_template calibration.md 60 "## Tiers by task type" "## Split patterns" "## Briefs need"

readme=$(cat "$T/README.md" 2>/dev/null)
assert_file "$T/README.md" "README.md exists"
for f in domain.md map.md review-checklist.md calibration.md; do
  assert_contains "$readme" "$f" "README mentions $f"
done

finish
