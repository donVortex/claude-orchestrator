---
max_turns: 8
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator]
---

[session-orchestrator] An orchestration is in progress. Ledger (.orchestration/ledger.md):

```markdown
# Orchestration: add user profiles
Started: 2026-11-03 · Backend: desktop · Base branch: main · Status: running

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T1 | profiles table + migration | src/db/schema.ts, src/db/migrations/** | — | deep | self | — | orch/T1 | #12 | merged |
| T2 | profile API endpoints + tests | src/api/users/** | T1 | standard | worker | local_ab12 | orch/T2 | #13 | pr-open |
| T3 | profile page + tests | src/ui/profile/** | T1 | standard | worker | — | — | — | planned |
| T4 | API docs | docs/api.md | T2 | fast | worker | — | — | — | planned |

## Events
- 10:02 T1 PR #12 merged by user
- 10:40 T2 report received → reports/T2.md
```

Continue with the session-orchestrator:orchestrating skill. The ledger is the source of truth.

(Planning check: the session tools are not available here. List the actions you will take next, in order, with the reason for each, then stop.)
