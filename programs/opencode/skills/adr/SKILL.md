---
name: adr
description: Capture Architecture Decision Records (ADRs) under docs/adr/. Apply the three-tests gate (hard-to-reverse, surprising-without-context, real-trade-off) before drafting. ADRs surface during grilling and planning are drafted inside the active plan directory; promotion to docs/adr/ happens when the ratifying step completes. Use the standalone /adr command outside a plan.
license: MIT
compatibility: opencode
---

# Architecture Decision Records

An ADR captures *that* a decision was made and *why*, so a future reader
who looks at the code and asks "why on earth did they do it this way?"
finds an answer instead of a guess.

ADRs live in `docs/adr/NNNN-slug.md`, sequentially numbered. The format is
deliberately small — most ADRs are a single paragraph.

## The Three Tests

Before drafting an ADR, the decision must pass **all three** of these tests.
If any test fails, do not record it.

1. **Hard to reverse.** The cost of changing your mind later is meaningful.
   Pick a colour for a button: trivially reversible, no ADR. Pick a
   database: weeks to swap out, ADR.

2. **Surprising without context.** A future reader will look at the code
   and wonder "why did they do it this way?" If the decision is the
   obvious default, no one will wonder, and no ADR is needed.

3. **The result of a real trade-off.** There were genuine alternatives and
   you picked one for specific reasons. If there was no real choice, there
   is nothing to record beyond "we did the only thing that worked".

Skipping the gate is the most common ADR failure mode. A bloated `docs/adr/`
becomes noise; a sparse one becomes signal.

See `references/adr-examples.md` for worked examples of decisions that pass
and fail the gate.

## Format

See `references/adr-format.md` for the full template. The minimum viable
ADR is:

```md
# {Short title of the decision}

{1–3 sentences: what's the context, what we decided, and why.}
```

Optional sections (only when they earn their keep):

- **Status frontmatter** (`proposed | accepted | deprecated | superseded by ADR-NNNN`)
- **Considered Options** — only when the rejected alternatives are worth remembering
- **Consequences** — only when non-obvious downstream effects need calling out

## Numbering

Files are named `NNNN-slug.md` with a 4-digit zero-padded number:
`0001-event-sourced-orders.md`, `0002-postgres-for-write-model.md`.

To assign a number: scan `docs/adr/` for the highest existing number, add
one. Numbers are never reused, even if the ADR is later deprecated or
superseded.

The slug is derived from the title: lowercase, hyphenated, drop articles
and punctuation. Keep it under 60 characters.

## Drafting During a Plan

While inside a plan (see `plan-driven-dev`), do **not** write directly to
`docs/adr/`. Instead:

1. Create `<plan-dir>/drafts/adr/` if it does not exist.
2. Write the draft to `<plan-dir>/drafts/adr/<slug>.md`. Do **not** assign
   a number yet — numbers are assigned at promotion time, after any other
   ADRs that landed in parallel.
3. Mark the step in `plan-implementation.md` that ratifies the decision
   with a `_Promotes_:` note pointing at the draft file. See
   `plan-driven-dev`.

The `/step` command promotes the draft when that step completes: it scans
`docs/adr/` for the next available number, renames the file to
`NNNN-<slug>.md`, and moves it into `docs/adr/`.

A decision is "ratified" when the step that depends on it (or the step
that the decision shapes) is implemented and verified. Decisions about
implementation choices typically promote alongside the implementation.
Decisions about constraints or boundaries typically promote alongside the
first step that exercises the boundary.

## Standalone Capture

Outside a plan, use the `/adr` command. It runs the three-tests gate, then
writes directly to `docs/adr/NNNN-slug.md`. Appropriate for retroactive
capture of decisions made before the plan-driven flow was adopted, or for
decisions that fall outside any active plan.

## Bootstrapping

For a repo with no `docs/adr/`, run `/bootstrap-adrs`. It surveys the
codebase for hard-to-reverse decisions visible in the architecture
(database choice, monorepo shape, deliberate framework deviations,
constraints embedded in CI configs), filters candidates through the three
tests, and presents each one for confirmation before writing.

## Amendments and Supersession

ADRs are immutable once written. If a decision is later overturned:

1. Write a new ADR explaining the new decision and why the old one was
   reversed.
2. Update the old ADR's status frontmatter to
   `superseded by ADR-NNNN` (where `NNNN` is the new ADR's number).
3. Do not edit the body of the old ADR. The historical record matters.

If a decision is no longer relevant but not actively reversed (e.g. the
component it described was removed), update its status to `deprecated` and
add a one-line note explaining why.
