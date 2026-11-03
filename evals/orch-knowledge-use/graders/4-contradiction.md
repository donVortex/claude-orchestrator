---
type: llm
weight: 1
---

The response is an orchestrator's breakdown and one draft brief for a pricing change, in a project with knowledge files (domain.md, map.md, review-checklist.md) and a CLAUDE.md that says "Round money half-up".

PASS if: it flags that domain.md (half-even) contradicts CLAUDE.md (half-up) and follows CLAUDE.md (half-up).

FAIL otherwise.
