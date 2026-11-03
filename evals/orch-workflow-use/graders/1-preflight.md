---
type: llm
weight: 1
---

The response is an orchestrator's plan for two tasks: a money helper in src/money/ (which matches the project's 'Money helper' recipe) and a CSV export in src/money/pricesCsv.js (same area, but a different kind of change, so it does not), in a project whose calibration.md has that recipe, a learned default (export new helpers from index.js) and a pre-flight check (ask for /add-dir before the first self task).

PASS if: it applies the pre-flight check: it mentions /add-dir up front (before or with the plan), or explains that no self task is planned so it isn't needed yet.

FAIL otherwise.
