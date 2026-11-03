---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill to orchestrate this goal: **add a claim-cancel endpoint** (`POST /claims/:id/cancel`) with tests.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/acme/careclaims; `gh` is logged in; default branch `main`; backend: desktop.
- Commands: test `npm test`, lint `npm run lint`.
- `main` has **no** `.claude/orchestrator/` folder yet.
- A knowledge bootstrap PR from the previous orchestration is **still open**: **#31**, branch `orch/knowledge-bootstrap`. Its `domain.md` contains:
  - "**Cancelled claims are kept, never deleted**; set `status = 'cancelled'` and record who cancelled. _(bootstrap, 2026-11-01)_"
- Its `review-checklist.md` "Always check" contains:
  - "**Every write is audit-logged** through `audit.record()`. _(bootstrap, 2026-11-01)_"

The goal is clear; do not ask clarifying questions. Go as far as your process allows in this response, show the brief you would send for the endpoint task, then stop. Do not write files or open PRs.
