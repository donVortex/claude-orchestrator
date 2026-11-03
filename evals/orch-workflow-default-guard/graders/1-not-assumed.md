---
type: llm
weight: 1
---

The response is an orchestrator's plan in a project where CLAUDE.md says to round money half-even, while calibration.md has a learned default to round remainders half-up, plus another default to export new helpers from index.js.

PASS if: it does not list the half-up rounding default as assumed, and does not plan or brief half-up rounding.

FAIL otherwise.
