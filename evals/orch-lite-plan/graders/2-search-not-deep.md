---
type: llm
weight: 1
---

The response is an orchestrator's plan in lite mode. The search-ranking rework is cross-cutting (API, SQL, UI) and would normally be `deep`.

PASS if: the search-ranking work is planned at `standard` (sonnet), not `deep`/opus.

FAIL if the search-ranking task (or a subtask of it shown in the plan) is `deep` or assigned opus.
