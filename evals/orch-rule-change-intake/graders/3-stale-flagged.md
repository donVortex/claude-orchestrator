---
type: llm
weight: 1
---

The response is an orchestrator's intake and plan. The entry "Refunds go through `refundOrder()` in `src/orders/refund.ts`" names a file and function that no longer exist on `main`.

PASS if: it flags that entry as stale or outdated (the file or function no longer exists) and says it will be updated or removed later (for example in the wrap-up's knowledge diff), or asks the user about it.

FAIL if it doesn't mention it, or presents the refund entry as current fact.
