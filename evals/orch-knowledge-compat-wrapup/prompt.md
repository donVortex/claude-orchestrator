---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill. The only task of this orchestration is merged (T1 → PR #90), so it's time for the wrap-up.

`.claude/orchestrator/` on `main` was written and curated by the team over many months, in its own layout:
- `domain.md`: **180 lines**, no budget header, headings `## Business rules` and `## Terms`.
- `reviews.md`: the team's review checklist, heading `## Always`.
- `exports.md`: export rules.
- There is **no** `calibration.md`, `map.md` or `review-checklist.md`.

No knowledge PR is open. `retros.md`:

```markdown
## T1 (worker, standard)
### Went badly
- [domain] Visit notes can be co-signed by a supervisor; the brief didn't say so and the first version rejected co-signed notes.
- [tier] The haiku implementer failed the CSV-escaping tests twice; sonnet passed first try.
### Improve
- [domain] Record that visit notes may be co-signed by a supervisor.
- [tier] Use sonnet for anything touching CSV escaping.
```

The knowledge files are not available here, so describe the diff instead of making it. Do the wrap-up.
