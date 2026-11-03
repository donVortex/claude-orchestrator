#!/usr/bin/env bash
# Plugin manifest, marketplace and line-ending rules.
. "$(dirname "$0")/lib.sh"

assert_file .claude-plugin/plugin.json "plugin.json exists"
assert_file .claude-plugin/marketplace.json "marketplace.json exists"

plugin=$(cat .claude-plugin/plugin.json 2>/dev/null)
market=$(cat .claude-plugin/marketplace.json 2>/dev/null)
attrs=$(cat .gitattributes 2>/dev/null)

assert_contains "$plugin" '"name": "claude-orchestrator"' "plugin name"
assert_contains "$market" '"name": "claude-orchestrator"' "marketplace name"
assert_contains "$market" '"source": "./"' "plugin source is the repo root"
assert_contains "$attrs" '*.sh text eol=lf' "shell scripts forced to LF"

if command -v node >/dev/null 2>&1; then
  for f in .claude-plugin/plugin.json .claude-plugin/marketplace.json; do
    node -e "JSON.parse(require('fs').readFileSync('$f','utf8'))" 2>/dev/null || fail "$f is valid JSON"
  done
fi

if command -v claude >/dev/null 2>&1; then
  claude plugin validate . >/dev/null 2>&1 || fail "claude plugin validate ."
else
  echo "SKIP: claude plugin validate (claude CLI not on PATH)"
fi

finish
