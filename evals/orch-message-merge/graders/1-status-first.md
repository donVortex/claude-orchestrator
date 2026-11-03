---
type: llm
weight: 1
---

The response is an orchestrator's message to the user after reviewing a clean PR (#10) that now needs the user to merge it.

PASS if: the message opens with a single short status line (one sentence) that says the PR (PR #10, or T1's PR) is reviewed and ready to merge, before any other content.

FAIL otherwise.
