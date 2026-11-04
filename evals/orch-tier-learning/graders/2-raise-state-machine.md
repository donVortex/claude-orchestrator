---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up. A refund state machine subtask in `src/orders/` escalated from `standard` to `deep`.

PASS if: the knowledge diff proposes an entry (a `Tier:` entry or one under Tiers by task type) making that kind of work (refund / order state machine) `deep`.

FAIL otherwise.
