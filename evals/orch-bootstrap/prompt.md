---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill to orchestrate this goal: **add a claim-status endpoint** (`GET /claims/:id/status`) with tests.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote `origin` → github.com/acme/careclaims; `gh` is logged in; default branch `main`; backend: desktop.
- Commands: test `npm test`, lint `npm run lint`.
- There is **no `.claude/orchestrator/` folder** on `main`.
- `CLAUDE.md` contains: "Never log patient identifiers."
- Tree:

```
README.md                 "CareClaims: claims processing for clinics"
CLAUDE.md
docs/architecture.md
src/phi/                  patient data access and redaction
src/claims/               claim intake and adjudication
src/api/                  HTTP routes
tests/                    mirrors src/
```

Go as far as your process allows in this response, then stop. Do not write files or open PRs.
