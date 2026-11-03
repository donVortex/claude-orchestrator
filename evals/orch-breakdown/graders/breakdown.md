---
type: llm
weight: 1
---

The response is an orchestrator's task breakdown for "add user profiles", shown for approval.

PASS only if all of these hold:
1. It is a table (or equivalent list) giving every task an id, what it does, the files it owns, its dependencies, a tier (`fast`, `standard` or `deep`) and a placement (`self`, `subagent` or `worker`).
2. The schema/migration work is its own task, placed `self`, with no dependencies, and tier `standard` or `deep` (not `fast`).
3. No two tasks that could run at the same time (neither depends on the other) list the same file. Directory globs count as overlapping with files inside them.
4. Endpoint work and UI work are each placed `worker` (or as part of `self` work), and depend on the schema task where they need it.
5. It ends by asking the user to approve or change the breakdown, and says nothing has been started yet.

FAIL if any point is missing or contradicted, or if the response claims to have started sessions or written code.
