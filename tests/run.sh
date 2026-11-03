#!/usr/bin/env bash
# Runs every tests/test_*.sh from the repo root; exits non-zero if any fails.
cd "$(dirname "$0")/.." || exit 1

status=0
for t in tests/test_*.sh; do
  out=$(bash "$t" 2>&1)
  if [ $? -eq 0 ]; then
    echo "PASS $t"
    echo "$out" | grep '^SKIP' | sed 's/^/    /'
  else
    echo "FAIL $t"
    echo "$out" | sed 's/^/    /'
    status=1
  fi
done
exit $status
