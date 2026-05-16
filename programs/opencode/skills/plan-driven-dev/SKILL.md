---
name: plan-driven-dev
description: Conventions for plan-driven development. Defines plan directory structure, file formats, active plan resolution, draft staging for context terms and ADRs, promotion rules, and squash exclusion rules.
license: MIT
compatibility: opencode
---

## Plan Directory Structure

A **plan directory** is any directory that contains a `plan.md` file. Each
plan directory contains the three core files plus an optional `drafts/`
subtree for in-flight context terms and ADRs:

- `plan.md` — the full plan: goals, context, constraints, design decisions
- `plan-implementation.md` — abridged, ordered task list distilled from the plan
- `task-log.md` — chronological, append-only log of step lifecycle events
- `drafts/` (optional) — staging area for unratified context terms and ADRs
  - `drafts/context/<term-slug>.md` — one file per drafted glossary term
  - `drafts/adr/<slug>.md` — one file per drafted ADR (no number assigned yet)
- `handovers/` (optional) — overflow store for oversized handover payloads
  - `handovers/step-<N>-attempt-<M>.md` — full handover content when the
    in-log entry would exceed the byte budget

The `drafts/` subtree only exists when something is being drafted. It is
created lazily by the `domain-language` and `adr` skills.

## Active Plan Resolution

Commands that operate on a plan resolve the target directory in this order:

1. **Explicit argument** — if `$1` is provided and contains a `plan.md`, use it
2. **`.active-plan` file** — if `.active-plan` exists in the project root, read
   the relative path from it
3. **Error** — if neither exists, instruct the user to run `/plan` or
   `/switch-plan`

## `.active-plan` File

A single-line file in the project root containing the relative path to the
active plan directory. Example contents:

```
webhook-retry
```

Created by `/plan`, updated by `/switch-plan`.

## Plan File Formats

### plan.md

Free-form. Should include:
- Problem statement / goal
- Context and constraints
- Design decisions and trade-offs
- Acceptance criteria

### plan-implementation.md

Numbered step list. Each step has:
- Step number
- Short title
- Description of what to implement
- Acceptance criteria for the step (how to know it's done)
- Optional `_Promotes_:` notes pointing at draft files this step ratifies

Steps may be amended. Amended steps use sub-numbering (e.g. 5a, 5b) or the
list is renumbered. Completed steps are marked with `[x]`.

The first step is conventionally a **tracer bullet** when the plan involves
code — the thinnest end-to-end slice that proves the wiring works. See the
`tdd` skill.

Example:

```markdown
# Implementation Steps

- [x] 1. **Tracer bullet** — Single retry on a 503 response, no backoff,
  observed end-to-end through the public webhook send API.
  _Done when_: a 503 followed by a 200 results in one delivery and one
  retry, both visible to the public API.

- [ ] 2. **Backoff with jitter** — Add backoff calculation with full jitter.
  _Done when_: two consecutive retries observe a delay greater than zero and
  bounded by the configured cap.
  _Promotes_: drafts/adr/retry-lives-in-webhook-module.md

- [ ] 3. **Dead-letter on giveup** — A delivery that exhausts retries is
  written to the dead-letter table.
  _Done when_: a 503 followed by N more 503s results in exactly one
  dead-letter row.
  _Promotes_: drafts/context/dead-letter.md
```

### task-log.md

The task log is a **strictly append-only** record of step lifecycle events.

**Rules:**

- New entries are always appended to the bottom of the file.
- Existing entries are **never** edited, reordered, moved, or deleted.
- Every entry carries an ISO 8601 UTC timestamp so chronological order is
  unambiguous even if the apparent order in the file is ever disturbed.
- Only the orchestrator (when running under `/do-plan`) writes entries
  with the multi-kind format below. The `@implement` subagent is forbidden
  from touching this file.
- `/step` and `/run-steps` continue to write the legacy single-kind
  `step-complete`-equivalent entry; this is allowed because they run
  attended and do not need the richer state machine.

**Entry kinds** (used by `/do-plan` and the orchestrator):

| Kind | When emitted | Closes a step? |
|------|--------------|----------------|
| `step-start` | Before delegating step N to `@implement` | no |
| `implement-handover` | `@implement` returned `handover-needed` | no |
| `feedback-round` | `@review` flagged a deviation; a new implement attempt is incoming | no |
| `step-complete` | Step finalized (verify+review pass, drafts promoted, squashed) | yes |
| `step-stopped` | Orchestrator halted on this step (budget exhausted, amend recommended, implement failed) | yes (terminal) |
| `orchestrator-handover` | Orchestrator self-handover between steps | no (resumable) |
| `run-summary` | Final summary at end of a `/do-plan` invocation | no |

**Closure semantics:** a step is considered closed when an entry of kind
`step-complete` or `step-stopped` exists for it. Any other kind leaves the
step open. A fresh orchestrator uses this to determine where to resume.

**Per-entry format**:

```markdown
## Step <N> — <kind>
**Time:** <ISO 8601 UTC, e.g. 2026-05-16T03:14:22Z>
<kind-specific fields>
```

**Kind-specific fields:**

`step-start`:
```markdown
**Title:** <step title>
**Attempt:** <M> of 2
```

`implement-handover`:
```markdown
**Attempt:** <M> of 2
**Reason:** <context exhaustion | step too large | repeated tool failure>
**Done so far:**
- <bullet>
**Remaining:**
- <bullet>
**Files touched:**
- <path>
**Next-attempt hint:** <one line>
```

If the payload exceeds ~1KB, write the full content to
`<plan-dir>/handovers/step-<N>-attempt-<M>.md` and replace the body with:

```markdown
**Overflow:** see handovers/step-<N>-attempt-<M>.md
**Reason:** <one line>
```

`feedback-round`:
```markdown
**Round:** <R> of 2
**Review alignment:** minor | significant
**Findings:**
- <bullet>
```

`step-complete`:
```markdown
**Title:** <step title>
**Verification:** pass (build, lint, tests)
**Promoted:** <list of promoted file paths, or "none">
**Summary:** <one line>
```

`step-stopped`:
```markdown
**Title:** <step title>
**Reason:** handover-budget-exhausted | feedback-budget-exhausted | implement-failed | review-recommends-amend
**Last attempt:** <one-line summary>
**Recommendation:** <e.g. /amend-plan, fix manually then resume>
```

`orchestrator-handover`:
```markdown
**Invocation:** /do-plan | direct
**Run state:**
- max-steps budget: <N> (<K> finalized this run)
- last finalized step: <step number>
- handovers this run: <count>
- feedback rounds this run: <count>
**Reason:** soft self-handover after <K> finalized step(s)
**Resume hint:** /do-plan <remaining>
```

`run-summary` (always the final entry of a `/do-plan` invocation):
```markdown
**Invocation:** /do-plan <args>
**Steps finalized this run:** <K>
**Steps remaining in plan:** <R>
**Stop reason:** budget-reached | plan-complete | <halt-kind>
**Last step touched:** <N> — <title> (<finalized|in-progress|stopped>)
**Per-step detail:**
- Step <N>: finalized — <H> handovers, <F> feedback rounds
**Recommended next:** <continue / /amend-plan / manual fix / done>
```

**Legacy entry format** (used by `/step` and `/run-steps`):

```markdown
## Step <number>: <title>
**Date:** <ISO date>
**Status:** completed | failed | partial
**Summary:** <what was implemented>
**Issues:** <any problems encountered, or "none">
**Verification:** <pass/fail, what was tested>
**Promotions:** <list of files promoted, or "none">
```

Both formats are append-only and may coexist in the same log.

### Resuming from the log

A fresh orchestrator determines where to resume by reading `task-log.md`
bottom-up and cross-referencing `plan-implementation.md` checkboxes:

1. Find the highest-numbered step that has either a `step-complete` or
   `step-stopped` entry. Call this the **last closed step**.
2. The next step to run is the next incomplete (`[ ]`) step in
   `plan-implementation.md` after the last closed step.
3. If the most recent entries describe a step that is *not* closed
   (`step-start`, `implement-handover`, `feedback-round` with no
   subsequent `step-complete`/`step-stopped`), the previous run died
   mid-step. The new orchestrator restarts that step from scratch; any
   partial code still in the staging area `@` is treated as work-in-progress
   that the next `@implement` attempt may build on.
4. If the most recent entry is `orchestrator-handover`, simply continue
   from the next incomplete step.

## Drafts and Promotion

Context terms and ADRs that surface during a plan are **drafted** inside the
plan directory rather than written directly to `docs/CONTEXT.md` or
`docs/adr/`. This keeps unratified content out of the canonical locations
until the change that ratifies it is implemented.

### Drafting

- A new context term is drafted to `<plan-dir>/drafts/context/<term-slug>.md`
  by the `domain-language` skill. One term per file. The file contains the
  raw entry in the same format as a `CONTEXT.md` Language entry.
- A new ADR is drafted to `<plan-dir>/drafts/adr/<slug>.md` by the `adr`
  skill. No ADR number is assigned at draft time.

### Promotion

The step that ratifies a draft must list it in a `_Promotes_:` note in
`plan-implementation.md`. When `/step` completes that step, it promotes the
listed drafts:

- **Context terms**: merge the drafted entry into `docs/CONTEXT.md` in the
  appropriate position (alphabetical inside the Language section, or inside
  the matching sub-heading group), then delete the draft file.
- **ADRs**: scan `docs/adr/` for the highest existing number, assign the
  next number, rename the draft to `NNNN-<slug>.md`, move into `docs/adr/`,
  then delete the draft directory entry.

Promotion is **strict**: only files explicitly listed under `_Promotes_:`
are moved. Drafts not listed are left in place; if they are still in
`drafts/` when the plan completes, the agent flags them.

### Why this matters

Drafts in the plan dir are kept out of work commits by the squash exclusion
rules below. Promoted files (in `docs/`) are squashed normally as part of
the work that ratifies them. This means: a context term or ADR enters the
codebase at exactly the moment the code that depends on it does.

## Squash Exclusion Rules

The following files are **never squashed** into work commits (`@-`):

- Any file inside a plan directory (any directory containing `plan.md`),
  including everything under `drafts/` and `handovers/`
- `.active-plan`

This applies to ALL plan directories in the project, not just the active
one. Detection is path-based: scan changed file paths and check whether any
ancestor directory contains a `plan.md`.

Files **outside** plan directories — including newly-promoted files in
`docs/CONTEXT.md` and `docs/adr/` — are squashed normally.

## Skill Loading

Commands and agents working with plans should load this skill. Additionally:

- Load `work` before any jj operations
- Load `conventional-commits` before writing commit messages
- Load `grill`, `domain-language`, `adr`, and `tdd` when planning or
  executing code-bearing work (see individual command files)
- Load language-specific skills as appropriate for the project
