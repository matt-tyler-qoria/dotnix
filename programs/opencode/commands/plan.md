---
description: Create a new plan directory and set it as the active plan
---

Load the `plan-driven-dev`, `work`, `grill`, `domain-language`, and `adr`
skills.

Verify the jj staging area is set up (run pre-flight from the `work` skill).

## Code or Non-Code?

Ask the user up front: **"Is this primarily a code change?"**

- **Yes** — also load the `tdd` skill. The step breakdown will enforce
  vertical slices and a tracer bullet first step.
- **No** — skip the `tdd` skill. The step breakdown is free-form (e.g. for
  infra, docs, or process work).

## Read Existing Documentation

Before grilling, read whatever exists:

- `docs/CONTEXT.md` if present — the project's existing glossary
- `docs/adr/` if present — list ADRs touching the area this plan affects;
  read the ones that look relevant

These ground the conversation in the project's existing language and
recorded decisions. Re-litigating them is waste.

## Grilling Phase — Draft `plan.md`

Use the `grill` skill to interview the user. Walk down the decision tree
one question at a time, proposing your recommended answer for each.

During grilling:

- When the user uses a fuzzy or overloaded term, sharpen it. If the term
  doesn't exist in `docs/CONTEXT.md`, draft it via the `domain-language`
  skill into `$1/drafts/context/<term-slug>.md`.
- When the user uses a term that conflicts with the existing glossary,
  call it out and resolve before continuing.
- When a load-bearing decision surfaces, run the `adr` skill's three-tests
  gate (hard-to-reverse + surprising-without-context + real-trade-off). If
  all three pass, draft the ADR into `$1/drafts/adr/<slug>.md`.

When the conversation reaches a stable shared understanding, write
`$1/plan.md` containing:

- Problem statement / goal
- Context and constraints (including any existing ADRs being respected)
- Design decisions and trade-offs
- Acceptance criteria

If any drafts were created during grilling, list them in a "Drafts"
section at the bottom of `plan.md` so they're easy to find later.

## Step Breakdown — Draft `plan-implementation.md`

Distill the plan into a numbered step list using the format defined in
the `plan-driven-dev` skill.

If this is a code change (`tdd` skill loaded):

- **Step 1 must be the tracer bullet.** Title it `**Tracer bullet** — ...`.
  Pick the thinnest end-to-end path through real code that proves the
  wiring. See `tdd` skill and `references/vertical-slices.md`.
- **Each step delivers one observable behaviour** through the public
  interface. Acceptance criteria phrased as "Done when: <observed
  behaviour>". Reject steps that test shape or scaffolding alone.
- **Steps that ratify a draft** must include `_Promotes_:` notes pointing
  at the relevant draft files in `$1/drafts/`.
- **Order steps**: tracer bullet → happy-path expansions → edge cases and
  error paths → operational concerns.

If this is not a code change, the step breakdown is free-form, but each
step should still have a clear "Done when" criterion.

Discuss the breakdown with the user before finalising. If any drafts are
not promoted by any step, raise it: either a step is missing a
`_Promotes_:` note, or the draft shouldn't have been created.

## Initialize Task Log

Write `$1/task-log.md` with a header only:

```markdown
# Task Log
```

## Activate

Write `$1` to `.active-plan` in the project root.

## Confirm

Show the user:

- The implementation steps
- Any drafts created in `$1/drafts/`
- Which step promotes each draft

Ask for confirmation before considering the plan complete. If the user
requests changes, revise and re-present.
