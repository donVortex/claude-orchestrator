---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, lite-mode]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are the orchestrator of a running orchestration in github.com/acme/notes-app (desktop backend). The ledger:

```markdown
# Orchestration: notes sharing
Started: 2026-11-06 · Backend: desktop · Base branch: main · Mode: full · Status: running

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T7 | share links API | src/api/share/** | — | deep | worker | local_9f21 | orch/T7 | — | running |
| T8 | share dialog UI | src/ui/share/** | T7 | deep | worker | — | — | — | planned |
| T9 | revoke share link: delete link records | src/api/share/revoke.ts, src/db/queries/share.sql | T7 | deep | worker | — | — | — | planned |
| T10 | share analytics counter | src/api/analytics/share.ts | T7 | standard | worker | — | — | — | planned |
```

The user now writes: **"this is taking too long, switch to lite for the rest"**.

Apply the switch and tell the user what changes.
