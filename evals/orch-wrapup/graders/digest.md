---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up after four merged tasks, based on retros in which three tasks report haiku failing on test-related work, one reports an unclear error shape in a brief, and one suggests giving docs tasks the test file paths.

PASS only if all of these hold:
1. It summarises the results (all four tasks merged, with their PRs).
2. It groups the retro points by tag, and identifies the repeated `[tier]` pattern (haiku failing at test writing, three times).
3. It proposes a concrete edit to `model-tiers.md`: test-writing work moves to `standard`/sonnet.
4. It proposes a concrete edit for the `[brief]` point (e.g. the brief template states error/response shapes).
5. It asks the user to approve the proposed edits before anything is changed, and does not claim to have changed any file.

FAIL if any point is missing or contradicted.
