---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up that extends an open knowledge PR (#58, branch `orch/knowledge-2026-11-01`).

PASS if it says the approved changes go onto that PR's own branch as in-place edits to the existing entries (a short statement is enough; it may also describe fetching or checking out the branch), rather than writing whole files based on `main` or opening a new PR.

FAIL if it would replace the branch's files wholesale, base the changes only on `main` without regard to the PR's content, or open a second knowledge PR.
