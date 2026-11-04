---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [worker, coexistence]
---

You are a worker session started by session-orchestrator. Load the session-orchestrator:working skill and follow it.

Skills available in this session besides session-orchestrator (listed for this check; they are not loadable here): `acme-review:security` — "Security review of a change".

# Brief: T4 · password reset token check

- Goal: add `isResetTokenValid(token, now)` that returns true when the token exists, is unused and is less than 30 minutes old.
- Acceptance: tested; `npm test` and `npm run lint` pass.
- Review checklist: `.claude/orchestrator/review-checklist.md` — sections: Always check, When touching `src/auth/`
- Skills: none · review: acme-review:security
- Owned files: `src/auth/resetToken.js`, `src/auth/resetToken.test.js`
- Off-limits: every other file
- Commands: test `npm test`, lint `npm run lint`, no build
- Base branch: `main`; PR branch: `orch/T4`
- Tier: standard — session sonnet / medium
- Orchestrator: desktop
- Report path: `/repo/.orchestration/reports/T4.md`
- Subtasks (files, tier hint, dependencies):
  - A. `isResetTokenValid()` with tests — `src/auth/resetToken.js`, `src/auth/resetToken.test.js` — standard — depends on: none

This is a planning check: the repository is not checked out here. Post your plan, including exactly how the work is reviewed before the PR, then stop before writing code or dispatching anything.
