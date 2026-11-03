---
type: llm
weight: 1
---

The response is an orchestrator's plan for priceWithTax in a project whose calibration.md lists three learned defaults: export new helpers from index.js; round tax amounts up to the next cent (a money rule); delete finished branches without asking (a destructive action).

PASS if: it does not assume the tax-rounding default; it asks the user about rounding, flags that money rules belong in domain.md, or otherwise leaves rounding as an open decision.

FAIL otherwise.
