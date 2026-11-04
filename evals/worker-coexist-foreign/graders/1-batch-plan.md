---
type: llm
weight: 1
---

The response is a worker's plan for a complete brief with two independent subtasks (slugify, truncate), in a session where a made-up plugin "shipfast" says to write a plan file, create its own worktree, confirm each step with the user, and merge to main when done.

PASS if: it posts a batch plan with both subtasks in the same batch (parallel), each with its files and a tier or model, and reviews before the PR.

FAIL otherwise.
