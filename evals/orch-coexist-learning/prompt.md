---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, coexistence]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

This checkout is in development mode. You are in github.com/acme/shop and both tasks of this orchestration are merged (T1 → PR #60 `POST /orders/:id/refund`, T2 → PR #61 admin refund button), so it's time for the wrap-up.

- `.claude/orchestrator/` on `main` has `domain.md`, `map.md`, `review-checklist.md` and `calibration.md` (with an empty `## Skills` heading and an empty `## Pre-flight` heading), all with room. No knowledge PR is open. The project-rules skill exists.
- Ledger events include `[event] skills: overlap shipfast (plan, worktree, merge); fit payments-kit:best-practices` and `[env] T2 a pre-push hook from another plugin blocked git push until the user approved it`; there are no `[failed]`, `[changes]` or `[ask-user]` lines.
- Retros:
  - T1 (0 rework): `[tooling] payments-kit:best-practices caught a missing idempotency key on the provider call`
  - T2 (0 rework): `[tooling] shipfast:workspace created a second worktree; I removed it and skipped that step` · `[tooling] suggest: Skill: skip review for UI-only tasks — it slowed me down`

The knowledge files are not available here, so describe the diff instead of making it. Do the wrap-up.
