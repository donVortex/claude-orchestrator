---
type: llm
weight: 1
---

The response is an orchestrator's breakdown and one draft brief for a pricing change, in a project with knowledge files (domain.md, map.md, review-checklist.md) and a CLAUDE.md that says "Round money half-up".

PASS if: the breakdown follows the map's pricing flow (schema, then service in src/pricing/, then route in src/api/, with tests), as tasks or ordered steps; tasks the change doesn't need may be left out.

FAIL otherwise.
