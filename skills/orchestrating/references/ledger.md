# Ledger and state files

All orchestration state lives in `.orchestration/` in the **main checkout** of the target repo. Nothing important lives only in your context: after compaction or resume, a SessionStart hook re-injects the ledger, and you continue from it.

## Setup (once per repo)

```bash
mkdir -p .orchestration/reports .orchestration/briefs
grep -qxF '.orchestration/' .git/info/exclude || echo '.orchestration/' >> .git/info/exclude
```

`.git/info/exclude` keeps it out of commits without touching `.gitignore`.

## Layout

```
.orchestration/
├─ ledger.md            # this orchestration's live state
├─ retros.md            # every retro, appended in arrival order
├─ briefs/T<n>.md       # the brief sent to each worker (and follow-up messages)
└─ reports/T<n>.md      # each worker's full report
```

## `ledger.md`

```markdown
# Orchestration: <goal>
Started: <date> · Backend: desktop|cli · Base branch: <branch> · Status: planning|running|wrap-up|done

| id | task | owns (files/globs) | depends | tier | placement | session/run | branch | PR | status |
|----|------|--------------------|---------|------|-----------|-------------|--------|----|--------|
| T1 | ... | src/db/schema.ts | — | deep | self | — | orch/T1 | #12 | merged |
| T2 | ... | src/api/users/** | T1 | standard | worker | local_ab12 | orch/T2 | #13 | in-review |

## Events
- <time> T2 started (local_ab12, sonnet/medium)
- <time> T2 report received → reports/T2.md
```

- The header's `Status:` must stay on line 2 — the hook reads the first lines, and stays silent once it says `done`.
- `session/run`: the desktop session id (`local_…`) or the CLI `session_id`.
- Add a `failures` note in the Events list each time a task fails a round (see the two-failure limit).

## Task statuses

`planned → running → blocked → pr-open → in-review → changes-requested → reviewed → merged`, or `failed` / `dropped`.

| Status | Means |
|---|---|
| `planned` | approved, not started (waiting for dependencies or a free slot) |
| `running` | worker (or you, for `self`) is working |
| `blocked` | waiting on an answer, a start click, or the user |
| `pr-open` | report received, PR not yet reviewed |
| `in-review` | you are reviewing |
| `changes-requested` | fixes sent back to the worker |
| `reviewed` | ready for the user to merge |
| `merged` | the user merged it |

## Update rule

Update the ledger **on every event** — start, question, answer, report, review, merge, failure — before doing anything else.

## `retros.md`

Append each report's `## Retro` section under a heading naming the task:

```markdown
## T2 (worker, standard)
<the report's Went well / Went badly / Improve sections, unchanged>
```

Write one for every `self` task too, in the same format.
