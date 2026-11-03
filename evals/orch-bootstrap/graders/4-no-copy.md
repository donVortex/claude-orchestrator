---
type: llm
weight: 1
---

The response is an orchestrator's first move in a repo that has no `.claude/orchestrator/` knowledge folder. The repo was not checked out for this check, so using the given facts in place of an actual scan is expected.

PASS if: it does not propose adding "Never log patient identifiers" as a new knowledge entry in its own words; referring to CLAUDE.md for that rule is fine, and so is saying it will be quoted in briefs.

FAIL otherwise.
