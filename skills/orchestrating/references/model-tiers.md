# Model tiers

The single source for which model and effort each piece of work gets. Edit this file to retune; nothing else hard-codes models. Agent files only carry a default `model`, and every caller passes the model from this table explicitly, which overrides that default.

## Tiers

| Tier | Subagent model | Worker session model / effort | Use for |
|---|---|---|---|
| `fast` | haiku | sonnet / low | search, lookups, renames, boilerplate, docs, mechanical edits |
| `standard` | sonnet | sonnet / medium | features with a clear spec, tests, bugs with a known cause |
| `deep` | opus | opus / high | design, cross-cutting changes, bugs with an unknown cause, security, reviewing deep work |

- **Subagent model**: the `model` passed on every Agent call for a subtask of this tier.
- **Worker session model / effort**: what the orchestrator sets on a worker session (desktop: `set_session_model` + `set_session_effort`; CLI: `--model` + `--effort`) for a task of this tier.
- A task's tier sets its session. Each subtask inside it gets its own tier, so one worker can mix models.
- The orchestrator session keeps whatever model the user started it with.

## Session floor

Worker sessions coordinate, plan and review, so they never run below **sonnet**, even for `fast` tasks. Only the subagents doing the work drop to haiku.

## Roles

| Agent | Role | Typical tiers |
|---|---|---|
| `orch-scout` | read-only search and summaries | `fast` |
| `orch-implementer` | implement one subtask test-first | `fast`, `standard` |
| `orch-specialist` | design, hard debugging, security, code review | `deep` (and reviews of `standard` work when asked) |

## Parallelism caps

```
max_parallel_workers: 4
max_parallel_implementers_per_session: 3
```

- `max_parallel_workers`: worker sessions the orchestrator runs at the same time.
- `max_parallel_implementers_per_session`: implementer subagents one session runs at the same time. Read-only scouts and reviews are not counted.

## Escalation

1. A subagent that fails, or returns weak work, is retried **once** on the next tier up (`fast` → `standard` → `deep`).
2. Record it in the retro with the `[tier]` tag: what failed, on which model, what fixed it.
3. A second failure is not retried again: the worker reports it to the orchestrator, which counts it toward the task's two-failure limit.
