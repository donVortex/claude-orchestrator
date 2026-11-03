---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, workflow]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start. Then orchestrate this goal:

**Add `splitBill(cents, people)` in `src/money/` that splits an amount between people, with tests.**

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/donVortex/orch-sandbox; `gh` is logged in; default branch `main`; backend: desktop. Commands: test `npm test`, lint `npm run lint`, no build.
- `CLAUDE.md` says: "Round money half-even (banker's rounding)."
- `.claude/orchestrator/calibration.md` on `main` contains:

```markdown
## Learned defaults
- **Round remainders half-up** unless told otherwise. _(T2 / PR #30; T1 / PR #34)_
- **Export new helpers from the area's `index.js`** unless told otherwise. _(T1 / PR #12; T1 / PR #20)_
```

The goal is clear; do not ask clarifying questions. Go as far as the approval gate, show the brief you would send, and stop.
