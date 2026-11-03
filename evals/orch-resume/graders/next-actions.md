---
type: llm
weight: 1
---

The response lists an orchestrator's next actions after resuming from a ledger where T1 is merged, T2 has an open PR with its report received, T3 is planned and depends only on T1, and T4 is planned and depends on T2.

PASS only if all of these hold:
1. It starts (or says it will start) T3 in this round, because its dependency T1 is merged. Its position in the list does not matter; reading reports or reviewing first is fine.
2. It reviews T2's PR (reading the report at reports/T2.md and/or the diff).
3. It does NOT start T4 yet, because T2 is not merged.
4. It does not re-plan or re-split the work, and does not ask the user to approve the breakdown again.

FAIL if any point is missing or contradicted.
