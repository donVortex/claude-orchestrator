---
type: llm
weight: 1
---

The response is an orchestrator's first move in a repo that has no `.claude/orchestrator/` knowledge folder. The repo was not checked out for this check, so using the given facts in place of an actual scan is expected.

PASS if: it describes the repo scan (planned, or done from the given facts), e.g. scouts reading the README, docs, CLAUDE.md, structure or tests.

FAIL otherwise.
