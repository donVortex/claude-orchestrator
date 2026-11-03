---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator]
---

Use the session-orchestrator:orchestrating skill to orchestrate this goal:

**Add user profiles**: a `profiles` table (`bio`, `avatar_url`) with a migration, `GET` and `PUT /users/:id/profile` endpoints with tests, a profile page in the UI with tests, and API docs for the new endpoints.

This is a planning check. The repository is not checked out here, so use these intake facts instead of running commands:

- Remote: `origin` → github.com/acme/app; `gh` is logged in; default branch `main`.
- Backend: desktop (session tools available).
- Commands: test `npm test`, lint `npm run lint`, build `npm run build`.
- Project knowledge: `.claude/orchestrator/` exists on `main`; none of its entries bear on this goal.
- Repository tree:

```
src/db/schema.ts              all table definitions
src/db/migrations/            one file per migration
src/api/users/routes.ts       user routes
src/api/users/handlers.ts     user handlers
src/api/users/handlers.test.ts
src/ui/components/Avatar.tsx
src/ui/profile/               (empty)
docs/api.md                   API reference
```

The goal is clear; do not ask clarifying questions. Go as far as the approval gate and stop there.
