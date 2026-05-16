---
description: Run the active plan end-to-end (or a bounded number of steps) via the orchestrator. Delegates each step to a fresh implementation subagent, reviews the result, and commits.
---

Load the `plan-driven-dev` and `work` skills.

This command is a thin wrapper. All real work is performed by the
`@orchestrator` subagent in an isolated context. The user's main session
sees only the final summary.

## Arguments

```
/do-plan [max-steps] [plan-dir]
```

Parse `$ARGUMENTS` as follows:

- **0 args** → `max_steps = unbounded`; resolve plan dir from `.active-plan`.
- **1 numeric arg** → `max_steps = $1`; resolve plan dir from `.active-plan`.
- **1 non-numeric arg** → `max_steps = unbounded`; `plan_dir = $1`.
- **2 args** → `max_steps = $1`, `plan_dir = $2`.

If `max_steps` is provided and is non-positive (≤ 0), report an error and
stop.

## Plan dir resolution

If `plan_dir` was not supplied, read `.active-plan` from the project root
and use its contents (a relative path) as `plan_dir`.

If neither was supplied and `.active-plan` does not exist, report an
error: instruct the user to run `/plan` or `/switch-plan` first.

If `plan_dir` does not contain `plan.md`, report an error and stop.

## Jira prefix

Attempt to derive the Jira prefix from the plan directory name. If the
basename matches the pattern `<PROJECT>-<NUMBER>-...` (e.g.
`PLAT-567-webhook-retry`), use `<PROJECT>-<NUMBER>` (e.g. `PLAT-567`).

If no prefix can be derived, prompt the user once for the Jira ticket ID
before delegating. Include the prefix in the orchestrator payload so the
orchestrator does not have to ask again per step.

## Delegate to orchestrator

Invoke the `@orchestrator` subagent with the structured payload:

```
plan_dir: <absolute path>
max_steps: <integer or "unbounded">
invocation: /do-plan
jira_prefix: <derived or user-supplied>
```

The orchestrator runs the per-step loop, handles all jj operations,
draft promotion, task-log writes, and self-handover. It returns a final
summary message.

## Output

Echo the orchestrator's final summary verbatim. Do not add commentary
that re-quotes large parts of the orchestrator's work — the
`task-log.md` is the source of truth and is on disk.

## Examples

- `/do-plan` — run the active plan to completion (or until a stop
  condition fires).
- `/do-plan 1` — run exactly one step then stop. Useful for smoke
  testing.
- `/do-plan 3` — run up to three steps then stop.
- `/do-plan 2 webhook-retry` — run two steps of a specific plan
  directory.

## Resuming

If the orchestrator self-hands-over, it prints a resume hint (e.g.
`/do-plan 4`). Simply re-invoke. A fresh orchestrator reads
`task-log.md` and `plan-implementation.md` to find the next step.

If the run halts on a step (handover budget exhausted, feedback budget
exhausted, etc.), the recommendation in the `step-stopped` entry tells
the user what to do — typically `/amend-plan` followed by re-invoking
`/do-plan`.
