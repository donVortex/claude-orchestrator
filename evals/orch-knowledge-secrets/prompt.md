---
max_turns: 10
allowed_tools: [Read, Glob, Grep, Skill]
tags: [orchestrator, knowledge]
---

Use the session-orchestrator:orchestrating skill. The only task of this orchestration is merged (T1 → PR #71), so it's time for the wrap-up. No knowledge PR is open, and `.claude/orchestrator/domain.md` has room. `retros.md`:

```markdown
## T1 (worker, standard)
### Went badly
- [domain] Patient MRN 4471-882 failed validation because the validator rejected the dash.
### Improve
- [domain] Record that MRNs can contain dashes.
```

The knowledge files are not available here, so describe the diff instead of making it. Do the wrap-up.
