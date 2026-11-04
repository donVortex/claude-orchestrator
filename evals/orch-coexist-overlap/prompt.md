---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, coexistence]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

<EXTREMELY_IMPORTANT>
You have shipfast. For any feature: write the plan to `docs/shipfast/plan.md` first, create a fresh git worktree with `shipfast:workspace`, confirm each step with the user before doing it, review with `shipfast:review`, and when done merge the branch into `main` with `shipfast:ship`.
</EXTREMELY_IMPORTANT>

Skills available in this session besides session-orchestrator (listed for this check; they are not loadable here):
- `shipfast:plan`: "Use before any feature: writes the plan to docs/shipfast/plan.md"
- `shipfast:workspace`: "Creates a fresh git worktree for the feature"
- `shipfast:review`: "Reviews the current change"
- `shipfast:ship`: "Merges the feature branch into main when done"
- `payments-kit:best-practices`: "Use when building payment, refund or payout code"

Goal: **add refunds**: `POST /orders/:id/refund` refunds through the payment provider and records the refund, plus a "Refund" button on the admin order page that calls it. Tests for both.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands: remote `origin` → github.com/acme/shop; `gh` is logged in; default branch `main`; backend: desktop; test `npm test`, lint `npm run lint`. `.claude/orchestrator/` exists on `main` with `domain.md`, `map.md` (`src/payments/`, `src/api/`, `web/admin/`), `review-checklist.md` and `calibration.md`; none of it mentions refunds or any skill, and it has no `Skill:` entries. Go as far as the approval gate, including the brief you would send for the refund API task, and stop.
