# opencode configuration

This directory holds the personal [opencode](https://opencode.ai) configuration
that ships with this nix flake. It is symlinked into `~/.config/opencode/` by
the home-manager modules in `hosts/`:

- `programs/opencode/agents/` → `~/.config/opencode/agents/`
- `programs/opencode/skills/` → `~/.config/opencode/skills/`
- `programs/opencode/commands/` → `~/.config/opencode/commands/`
- `programs/opencode/rules/AGENTS.md` → `~/.config/opencode/AGENTS.md`

The configuration encodes one opinionated workflow: **plan-driven, jujutsu-
backed, test-first development with bounded autonomy.** The pieces below
exist to make that workflow predictable and resumable.

---

## Directory layout

```
programs/opencode/
├── agents/      # Subagent definitions (Markdown with YAML front-matter)
├── commands/    # Slash commands available in the chat
├── rules/       # Project-wide rules loaded for every session
│   └── AGENTS.md
└── skills/      # Loadable skill bundles (one folder per skill)
```

---

## Concepts

### Plan directory

Any directory containing a `plan.md`. A plan directory always carries:

| File | Purpose |
|------|---------|
| `plan.md` | Free-form goal, context, constraints, design decisions |
| `plan-implementation.md` | Ordered, checkbox-style step list |
| `task-log.md` | **Append-only** chronological log of step lifecycle events |
| `drafts/` (optional) | Unratified context terms and ADRs awaiting promotion |
| `handovers/` (optional) | Overflow store for oversized handover payloads |

The active plan is identified by the single-line `.active-plan` file in the
project root.

### Jujutsu staging area

All work happens in a working-copy commit `@` (the "staging area"). Its
parent `@-` is the **work commit** that will eventually be pushed. Plan
files and `.active-plan` live in `@` and are never squashed down to `@-`.
Code changes are selectively squashed.

This separation lets the in-flight scratch (plans, drafts, logs) coexist
with finished work in a clean commit graph.

### Drafts and promotion

Glossary terms (`docs/CONTEXT.md`) and ADRs (`docs/adr/NNNN-*.md`) surfaced
during planning are first drafted inside the plan directory under `drafts/`.
The step in `plan-implementation.md` that ratifies a draft carries a
`_Promotes_:` note pointing at it. When that step finalizes, the draft is
promoted to its canonical home and the draft file is deleted.

### Task log entry kinds

`task-log.md` is strictly append-only. Entries are timestamped (ISO 8601
UTC). When `/do-plan` is driving execution, the orchestrator writes
structured entries of these kinds:

| Kind | Closes a step? | Emitted when |
|------|----------------|--------------|
| `step-start` | no | Before delegating step N to `@implement` |
| `implement-handover` | no | `@implement` returned `handover-needed` |
| `feedback-round` | no | `@review` flagged a deviation; new implement attempt incoming |
| `step-complete` | yes | Step verified, reviewed, drafts promoted, code squashed |
| `step-stopped` | yes | Step halted (handover/feedback budget exhausted, etc.) |
| `orchestrator-handover` | no | Orchestrator self-hand-over between steps |
| `run-summary` | no | Final entry of any `/do-plan` invocation |

The interactive `/step` and `/run-steps` commands continue to write the
legacy single-kind entry. Both formats may coexist.

---

## Agents

Subagents are single-purpose actors with constrained tool profiles. The
calling agent delegates to them; they return a single message.

| Agent | Mode | Edits? | jj? | Purpose |
|-------|------|--------|-----|---------|
| `@general` | subagent | yes | yes | Research and multi-step tasks |
| `@explore` | subagent | no | no (bash allowed) | Fast read-only code exploration |
| `@verify` | subagent | no | no (bash allowed) | Run build/lint/tests on `@-` changes |
| `@review` | subagent | no | jj-only | Plan-intent alignment check on `@-` |
| `@implement` | subagent | yes | **denied** | Implement one plan step (TDD + verify) |
| `@orchestrator` | subagent | yes | yes | Drive `/do-plan`'s per-step loop |

The `@implement` and `@orchestrator` agents back the `/do-plan` workflow
(see below). They are also invokable directly for testing.

---

## Skills

Skills are loadable bundles of instructions. They are loaded explicitly by
commands and by agents that mention them. Loading a skill injects its
content into the current context.

### Workflow skills

- `work` — jj staging-area pre-flight, commit discipline (atomic commits,
  one logical change per commit), Jira-prefixed Conventional Commit
  messages. Loaded at the start of every session via `rules/AGENTS.md`.
- `plan-driven-dev` — plan directory layout, file formats, active plan
  resolution, draft/promote flow, task-log entry kinds, append-only rule,
  resume-from-log semantics, squash exclusion rules.
- `jujutsu` — jj command reference. Loaded whenever the repo has `.jj/`.
- `conventional-commits` — Conventional Commits v1.0.0 spec.
- `tdd` — red/green/refactor loop, vertical slices, tracer-bullet first
  step.
- `grill` — interview pattern (one question at a time, propose recommended
  answers).
- `domain-language` — `docs/CONTEXT.md` format, term selection criteria.
- `adr` — Architecture Decision Record format, three-tests gate
  (hard-to-reverse + surprising-without-context + real-trade-off).

### Language skills (Go-heavy at present)

- `golang-code-style`, `golang-naming`, `golang-error-handling`,
  `golang-safety`, `golang-data-structures`, `golang-design-patterns`,
  `golang-testing`, `golang-troubleshooting`, `golang-security`,
  `golang-documentation`, `golang-modernize`, `golang-repository-setup`,
  `golang-database`
- `designing-application-transactions` — application-level patterns for
  CockroachDB.

---

## Commands

Slash commands invoked from the chat. Most either delegate to subagents or
walk through a structured procedure with the user.

### Bootstrap

- `/bootstrap-context` — Survey the codebase and seed `docs/CONTEXT.md`.
- `/bootstrap-adrs` — Survey the codebase, apply the three-tests gate, and
  seed `docs/adr/`.

### Free-standing capture (outside any plan)

- `/context [term]` — Add or amend one term in `docs/CONTEXT.md`.
- `/adr` — Capture one ADR.

### Plan lifecycle

- `/plan <plan-dir>` — Grill the user, draft `plan.md`, distil
  `plan-implementation.md`, initialise `task-log.md`, write
  `.active-plan`. Drafts created during grilling are staged for promotion.
- `/switch-plan [plan-dir]` — Change the active plan. If no argument,
  lists all plan directories with progress.
- `/amend-plan [issues...]` — Modify future (incomplete) steps in
  `plan-implementation.md`. Completed steps are never amended.
- `/review-plan` — Read-only progress check against plan intent.

### Step execution (interactive)

- `/step` — Execute the next incomplete step. Calls `@verify`. Promotes
  drafts. Squashes. Logs to `task-log.md`.
- `/run-steps [N]` — Execute up to N steps. After each, calls `@verify`
  then `@review`. Stops on verify failure or significant review deviation.
- `/review-step` — Re-run `@review` against the most recently completed
  step.

### Step execution (autonomous)

- `/do-plan [max-steps] [plan-dir]` — Drive the plan via the
  `@orchestrator` subagent. The orchestrator delegates each step to a
  fresh `@implement`, reviews with `@review`, promotes drafts, squashes,
  and logs. Returns a structured summary.

### Mechanical helpers

- `/squash` — Selectively squash code into `@-`, excluding all plan files
  and `.active-plan`.

---

## The `/do-plan` workflow

`/do-plan` is the autonomous counterpart to `/step` and `/run-steps`. It
is designed for unattended runs, but with hard bounds at every level so
context cannot explode and a botched step cannot derail the plan.

### Roles

```
USER
 └─ /do-plan [max-steps] [plan-dir]      ← thin command wrapper
     └─ @orchestrator (fresh subagent, isolated context)
         ├─ per-step loop
         │   ├─ ensure work commit for step N (work skill pre-flight)
         │   ├─ @implement (fresh per step / per feedback round)
         │   │   └─ TDD → verify (build, lint, tests)
         │   │      MUST pass before returning status: complete
         │   ├─ @review (read-only intent check on @-)
         │   ├─ if aligned → promote drafts → squash → log → next step
         │   └─ if deviated → fresh @implement with feedback (≤2 rounds)
         └─ run-summary
```

The user never sees the orchestration churn. `/do-plan` returns one
summary message; the per-step detail lives in `task-log.md`.

### Bounds

| Bound | Default | Behaviour on exceed |
|-------|---------|---------------------|
| `max-steps` | unbounded | Graceful stop with `budget-reached` |
| Handover attempts per step | 2 | Halt with `handover-budget-exhausted` |
| Review feedback rounds per step | 2 | Halt with `feedback-budget-exhausted` |
| Orchestrator self-handover (soft) | after 1 finalized step | Clean exit between steps with `orchestrator-handover` |

The orchestrator self-handover keeps its own context small. A fresh
`/do-plan` invocation reconstructs state from `task-log.md` plus the
checkboxes in `plan-implementation.md` — no separate run-state file.

### Handover protocol

`@implement` may return `handover-needed` if context is filling up or the
step is materially larger than its description suggested. Any partial
code is left in the working copy. The orchestrator logs an
`implement-handover` entry and spawns a fresh `@implement` with the
handover content as `prior_feedback`. Two handovers in a row halt the
step — the step is genuinely mis-sized and `/amend-plan` is required.

### Halt conditions

`/do-plan` halts (vs gracefully stops) when:

- `@implement` returns `status: failed`
- Handover budget exhausted (2 attempts)
- Feedback budget exhausted (2 review rounds without alignment)
- `@review` recommends `amend plan`

Each halt writes a `step-stopped` entry with a `recommendation` field
telling the user what to do next.

### Direct invocation

`@orchestrator` is also invokable directly for testing. The payload is
the same as `/do-plan` passes:

```
plan_dir: <abs path>
max_steps: <integer or "unbounded">
invocation: direct
jira_prefix: <e.g. PLAT-567>
```

---

## End-to-end example

A typical session for a code change might look like:

```
# 1. Set up a new plan (interactive grilling, drafts may be created)
/plan webhook-retry

# 2. Iterate the plan/steps with the user
/review-plan
/amend-plan

# 3. Bootstrap or refine surrounding docs if needed
/bootstrap-context
/bootstrap-adrs

# 4. Execute, interactively (one step at a time)
/step
/step
# ...or batched but supervised
/run-steps 3

# 5. Or hand off the rest to the orchestrator
/do-plan 1            # smoke test the workflow
/do-plan              # let it run to completion (or self-handover)
/do-plan              # resume after a self-handover

# 6. If something drifts
/review-step
/amend-plan "<what changed>"
/do-plan
```

Throughout, the staging area `@` accumulates plan-directory changes
(plans, logs, drafts) while finished code is squashed into a clean
per-step work commit `@-`. The commit graph stays linear and readable;
the plan directory stays out of the work history.

---

## Adding new components

### New skill

1. Create `programs/opencode/skills/<name>/SKILL.md` with YAML
   front-matter (`name`, `description`, `license`, `compatibility`).
2. Reference it from the commands or agents that should load it.
3. Rebuild home-manager to symlink it.

### New agent

1. Create `programs/opencode/agents/<name>.md` with YAML front-matter
   (`description`, `mode`, `model`, `permission`).
2. Constrain `permission.edit` and `permission.bash` as tightly as the
   role allows.
3. Rebuild home-manager.

### New command

1. Create `programs/opencode/commands/<name>.md` with YAML front-matter
   (`description`).
2. The body is the procedure the calling agent follows when the user
   invokes the slash command.
3. Rebuild home-manager.

---

## Rebuilding

After editing anything in this directory:

```bash
darwin-rebuild switch --flake .
```

The home-manager modules copy the contents into `~/.config/opencode/` on
the next switch. Restart any active opencode sessions to pick up
agent/skill/command changes.
