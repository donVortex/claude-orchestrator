---
type: llm
weight: 1
---

The response is an orchestrator's breakdown and one draft brief for a pricing change, in a project with knowledge files.

PASS only if all of these hold:
1. The breakdown follows the map's pricing flow (schema → service in `src/pricing/` → route in `src/api/` → tests), as tasks or as ordered steps.
2. The brief for the `src/pricing/` task has a Project rules field that quotes the integer-cents rule.
3. The brief or the described review includes the audit-log check from the review checklist.
4. It flags that `domain.md` ("half-even") contradicts `CLAUDE.md` ("half-up"), and follows `CLAUDE.md` (half-up) for this work.
5. It asks for approval and starts nothing.

FAIL if any point is missing or contradicted.
