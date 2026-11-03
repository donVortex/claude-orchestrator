# Worker report format

Every worker ends with exactly one report, written to the path in its brief (`<main checkout>/.orchestration/reports/<task-id>.md`). The orchestrator reads these headings, so keep them exactly.

```markdown
# T<n> report
Status: done | blocked | failed
PR: <url, or "none">

## Result
- Changed: <files and what changed, one line each>
- Verified by: <command> → <real outcome>   (one line per command: tests, lint, build)
- Risks / follow-ups: <anything the reviewer should look at; "none" if none>

## Retro
### Went well
- [tag] <what helped, concretely>
### Went badly
- [tag] <what cost time or quality, concretely>
### Improve
- [tag] <a concrete change to a brief, the split, the rubric, tooling or the codebase>
```

For `Status: blocked`, add a `## Question` section after `## Result` with the one question you need answered and the options you see.

## Tags

| Tag | Use for |
|---|---|
| `brief` | the brief was unclear, wrong or missing something |
| `split` | the task boundary or file ownership was wrong |
| `tier` | a model was too weak or more than needed; escalations |
| `parallelism` | parallel batches helped, or collided |
| `tooling` | commands, permissions, scripts, CI |
| `codebase` | the code itself made the work harder or easier |
| `process` | anything about the working loop itself |
| `domain` | a rule, term or codebase fact the project's knowledge (`.claude/orchestrator/`) should record — state the rule, not the value: "MRNs may contain dashes", never a real record ID or personal data |

## Rules

- One point per line, tag first.
- Every "Went badly" point gets a matching "Improve" point with the same tag.
- Concrete beats general: "brief didn't say errors are `{code, message}`" — not "brief could be clearer".
- An empty section is `- none`, never omitted.
