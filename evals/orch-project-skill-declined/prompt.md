---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start. You are in donVortex/orch-sandbox and the only task of this orchestration is merged (T1 → PR #50), so it's time for the wrap-up.

- `.claude/orchestrator/` on `main` has `domain.md` (12 rules about money and argument errors), `map.md`, `review-checklist.md` and `calibration.md`, all with room. There is **no** `.claude/skills/` folder in the repo.
- No knowledge PR is open. The retro has one `[domain]` point: "Prices in CSV exports use the same European format as the UI."
- `.orchestration/archive/2026-11-04-max-price/ledger.md` contains: `- 2026-11-04 [event] project skill: declined by the user`

The knowledge files are not available here, so describe the diff instead of making it. Do the wrap-up.
