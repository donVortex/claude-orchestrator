---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up that should propose a knowledge diff for `domain.md`, which is at its 150-line budget, while knowledge PR #58 is still open.

PASS only if all of these hold:
1. It proposes recording the 45-day quote expiry and the stacking rule with its 15% cap, each with a source like `T1 / PR #61` and `T2 / PR #62`.
2. It replaces, edits or removes the two outdated entries (30 days; never stack), so `domain.md` stays within 150 lines.
3. It plans to add these changes to the open PR #58 (branch `orch/knowledge-2026-11-01`), not to open a second knowledge PR.
4. It asks the user to approve the diff before changing anything, and claims no file was changed.

FAIL if any point is missing or contradicted.
