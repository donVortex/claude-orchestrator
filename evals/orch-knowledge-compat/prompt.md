---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill to orchestrate this goal: **add an export of a patient's visit history as CSV** with tests.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/acme/clinicnotes; `gh` is logged in; default branch `main`; backend: desktop.
- Commands: test `npm test`, lint `npm run lint`.
- `.claude/orchestrator/` exists on `main`. The team wrote and curated it over many months. Its layout differs from today's plugin templates: it has no budget headers, `domain.md` uses `## Business rules` instead of `## Rules` and has no `## Glossary`, `review-checklist.md` is called `reviews.md`, there is no `calibration.md`, and there is an extra file `exports.md`.

`domain.md`
```markdown
# Domain
## Business rules
- Visit notes are owned by the clinic, not the practitioner.
- Exports of patient data require a consent record created in the last 12 months.
```

`reviews.md`
```markdown
## Always
- Every export path writes an audit event.
```

`exports.md`
```markdown
- CSV exports use semicolons, because the clinics' spreadsheet locale treats commas as decimal marks.
```

The goal is clear; do not ask clarifying questions. Go as far as the approval gate, show the brief you would send for the export task, and stop.
