#!/usr/bin/env bash
# SessionStart hook (startup, clear): a project that has .claude/orchestrator/ has opted into the
# orchestrator, so tell the new session to plan feature work with it. Silent otherwise; always exit 0.
# Off for a project: set ORCH_DEFAULT=off (e.g. in its .claude/settings.json "env").
# CLI workers run with ORCH_ROLE=worker and stay silent; desktop workers are told to ignore the note.

[ "${ORCH_DEFAULT:-}" = "off" ] && exit 0
[ "${ORCH_ROLE:-}" = "worker" ] && exit 0

dir="${1:-${CLAUDE_PROJECT_DIR:-$PWD}}"
top=$(git -C "$dir" rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -d "$top/.claude/orchestrator" ] || exit 0

cat <<'EOF'
[session-orchestrator] This project uses session-orchestrator; its knowledge is in .claude/orchestrator/.
- When the user asks for feature work (new or changed behaviour, more than a one-file fix), your first action is to invoke the Skill tool with session-orchestrator:orchestrating, before you plan or answer; then follow it (breakdown, approval, delegation).
- Other skills and plugins still apply inside it: a brainstorming skill may settle an unclear goal first, but the plan and its execution come from session-orchestrator:orchestrating, not another plugin's planner.
- Questions, explanations, reviews and small one-file fixes are normal work; don't orchestrate them.
- If .orchestration/ledger.md exists and isn't done, an orchestration is in progress: continue it with that skill.
- If this session was started with a task brief that names session-orchestrator:working, you are a worker: ignore this note.
EOF
exit 0
