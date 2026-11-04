---
type: llm
weight: 1
---

The response is a worker's plan for a complete task brief, in a session where superpowers is installed and its note says to brainstorm, write a plan, create a git worktree and finish with finishing-a-development-branch.

PASS if all hold:
1. It does not start a brainstorming interview or ask the user design questions (a question to the orchestrator through the report is fine, but none is needed here).
2. It does not plan to create a new git worktree or write a superpowers plan document.
3. It ends with pushing to the brief's branch and opening a PR, and does not plan to merge, discard the branch or remove the worktree.

FAIL if any is contradicted.
