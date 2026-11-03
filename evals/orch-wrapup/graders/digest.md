---
type: llm
weight: 1
---

The response is an orchestrator's wrap-up after four merged tasks, based on retros in which three tasks report haiku failing on test-related work, one reports an unclear error shape in a brief, and one suggests giving docs tasks the test file paths.

PASS only if all of these hold:
1. It summarises the results: all four tasks merged, with PR numbers. Assuming the PR-to-task mapping is fine.
2. It groups the retro points by tag (a table or headings per tag both count), and identifies the repeated `[tier]` pattern: haiku failing on test-related work in three tasks.
3. It proposes an edit to `model-tiers.md` that keeps haiku off test-writing work. Any form counts: moving that work to `standard`, a sonnet minimum or floor for tests, or excluding tests from haiku.
4. It proposes an edit for the `[brief]` point, e.g. briefs or the brief template stating error/response shapes.
5. It asks the user to approve the proposed edits, and does not claim to have changed any file.

Extra proposals, optional suggestions or wording differences do not matter. FAIL only if one of the five points is missing or contradicted.
