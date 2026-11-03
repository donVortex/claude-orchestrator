---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, workflow]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start. Then orchestrate this goal:

**Add `averagePrice(cents)` in `src/money/` with tests, and add a CSV export of all prices as `pricesCsv(prices)` in `src/money/pricesCsv.js` with tests.**

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/donVortex/orch-sandbox; `gh` is logged in; default branch `main`; backend: desktop. Commands: test `npm test`, lint `npm run lint`, no build.
- `.claude/orchestrator/` exists on `main`. Its `domain.md` rules include:
  - "**Money is EUR, passed around as integer cents.** _(user, 2026-11-03)_"
  - "**A number argument of the wrong type throws `TypeError('<fn>: <arg> must be a number')`; a fraction, `NaN` or `Infinity` where a whole number is needed throws `RangeError('<fn>: <arg> must be an integer')`.** _(T1 / PR #10, 2026-11-03)_"
  - "**Money is shown European style:** `1.234,50 €`. _(user, 2026-11-03)_"

  Its `calibration.md` contains:

```markdown
## Recipes
- **Money helper** (`src/money/<fn>.js`): one worker, `standard`, small-task path; brief quotes the number-argument and display rules, names `src/money/format.js` as style reference, folds the `index.js` export line into the same subtask. Last 2 runs: 0 attention, 0 rework. _(T1 / PR #10; T1 / PR #12)_

## Learned defaults
- **Export new helpers from the area's `index.js`** unless told otherwise. _(T1 / PR #12; T1 / PR #20)_

## Pre-flight
- **Ask for `/add-dir <repo>-wt` before the first `self` task**; runs without it stalled on prompts. _(T3 / PR #6)_
```

The goal is clear; do not ask clarifying questions. Go as far as the approval gate, show the brief you would send for the `src/money/` task, and stop.
