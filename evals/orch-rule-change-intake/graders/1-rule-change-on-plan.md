---
type: llm
weight: 1
---

The response is an orchestrator's intake and plan. The user's goal (guests may buy gift cards) changes a recorded project rule ("Gift cards can only be bought by signed-in customers").

PASS if: the plan explicitly shows that the goal changes this rule, from the old version to the new one (a `Changes rule: … → …` line or an equally clear old → new statement), and the user's approval of the plan (or an explicit question) is what confirms the change.

FAIL if it doesn't mention that the rule changes, or treats the old rule as still binding without raising it.
