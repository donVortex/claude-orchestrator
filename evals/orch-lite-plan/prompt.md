---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, lite-mode, tiers]
---

First load the session-orchestrator:orchestrating skill with the Skill tool, as an orchestrator session does at its start.

You are in github.com/acme/notes-app (standalone install, desktop backend). This session runs on opus. The user's goal: **"Add a CSV export of notes, rework how search ranks results (title matches first, then recency, across the API and the UI), and make password-reset tokens expire after 30 minutes instead of 24 hours."**

Intake facts (you can't run commands here; these are their results):
- No `.orchestration/ledger.md`; the previous orchestration is archived and its tasks went up to T6. `git remote` and `gh auth status` work; commands are `npm test`, `npm run lint`, `npm run build`. No overlapping workflow skills, no pre-flight entries.
- `.claude/orchestrator/calibration.md` on `main` has, under `## Mode`: "**Mode: lite** — small codebase, low-risk changes; the user chose lite in two runs. _(T2 / PR #14; T5 / PR #19)_". Nothing under Tiers by task type.
- A scout found: notes export would live in `src/api/export.ts` plus a button in `src/ui/NotesList.tsx`; search ranking spans `src/api/search.ts`, `src/db/queries/search.sql` and `src/ui/SearchResults.tsx`; reset tokens are created in `src/auth/reset.ts`.

Do the intake and show the plan for approval.
