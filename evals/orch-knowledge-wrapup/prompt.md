---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill. All tasks of this orchestration are merged (T1 → PR #61, T2 → PR #62), so it's time for the wrap-up. Facts:

- `.claude/orchestrator/domain.md` on `main` is at **150 of 150 lines**. Two of its entries are now wrong:
  - "**Quotes expire after 30 days.** _(bootstrap, 2026-10-01)_" — T1 changed expiry to 45 days.
  - "**Discounts never stack.** _(T4 / PR #50, 2026-10-12)_" — T2 introduced stacking for annual prepay + loyalty, capped at 15%.
- A knowledge PR is still open: **#58**, branch `orch/knowledge-2026-11-01`.
- `retros.md`:

```markdown
## T1 (worker, standard)
### Went badly
- [domain] Brief said quotes expire after 30 days, but product changed it to 45 days in this task.
### Improve
- [domain] Record quote expiry as 45 days.

## T2 (worker, standard)
### Went badly
- [domain] Knowledge said discounts never stack; annual prepay + loyalty now stack, capped at 15%.
### Improve
- [domain] Record the stacking rule and its 15% cap.
```

The knowledge files are not available here, so describe the diff instead of making it. Do the wrap-up.
