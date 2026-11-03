---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill to orchestrate this goal: **add a monthly-premium discount for annual prepayment** (10% off) with tests.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/acme/insurely; `gh` is logged in; default branch `main`; backend: desktop.
- Commands: test `npm test`, lint `npm run lint`.
- `CLAUDE.md` contains: "Round money half-up."
- `.claude/orchestrator/` exists on `main`:

`domain.md`
```markdown
<!-- budget: 150 lines -->
## Rules
- **Premiums are integer cents**, never floats. _(T2 / PR #42, 2026-10-10)_
- **Round money half-even** (banker's rounding). _(T5 / PR #51, 2026-10-14)_
- **Quotes expire after 30 days.** _(bootstrap, 2026-10-01)_
```

`map.md`
```markdown
<!-- budget: 100 lines -->
## Areas
- **`src/pricing/`** — premium calculation. _(bootstrap, 2026-10-01)_
- **`src/api/`** — HTTP routes. _(bootstrap, 2026-10-01)_
## Feature flows
- **Pricing change:** schema in `src/db/schema.ts` → service in `src/pricing/` → route in `src/api/` → tests beside each file. _(T3 / PR #44, 2026-10-11)_
```

`review-checklist.md`
```markdown
<!-- budget: 60 lines -->
## Always check
- **Every write is audit-logged** through `audit.record()`. _(bootstrap, 2026-10-01)_
```

The goal is clear; do not ask clarifying questions. Go as far as the approval gate, show the brief you would send for the task that changes `src/pricing/`, and stop.
