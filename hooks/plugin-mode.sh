#!/usr/bin/env bash
# SessionStart hook: says "development mode" only when the plugin runs from its own development
# checkout, which has a git-ignored .plugin-dev marker. Installs from GitHub never have the marker,
# so they run standalone and print nothing. ORCH_PLUGIN_MODE=standalone (or EVAL_ORCH_PLUGIN_MODE, the
# only form plugin eval cases may set) forces standalone.

[ "${ORCH_PLUGIN_MODE:-${EVAL_ORCH_PLUGIN_MODE:-}}" = "standalone" ] && exit 0
[ -f "${CLAUDE_PLUGIN_ROOT:-}/.plugin-dev" ] || exit 0

echo "[session-orchestrator] development mode: this is the plugin's development checkout, so wrap-ups may propose plugin edits."
exit 0
