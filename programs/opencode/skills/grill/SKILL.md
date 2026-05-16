---
name: grill
description: Interview discipline for stress-testing plans, designs, and decisions. Walk down each branch of the design tree one question at a time, propose recommended answers, sharpen vocabulary, and surface decisions worth recording. Use during planning, design reviews, or whenever alignment with the user matters.
license: MIT
compatibility: opencode
---

# Grill

A grilling session is a disciplined interview. Its purpose is to close the gap
between what the user thinks they want and what would actually be built. Most
software defects are alignment defects — surface them now, not after
implementation.

## Core Rules

1. **One question at a time.** Wait for the answer before moving on. Batched
   questions get batched (shallow) answers.

2. **Always propose your recommended answer.** Frame each question as "I'd
   recommend X because Y — agree, or push back?" The user reacts faster to a
   proposal than to an open question, and the reasoning shows your work.

3. **Prefer exploration over interrogation.** If a question can be answered by
   reading the codebase, existing docs, an ADR, or `docs/CONTEXT.md`, go look
   instead of asking. Only ask the user for things that genuinely require their
   input (intent, preferences, business context).

4. **Walk the decision tree, resolving dependencies first.** If decision B
   depends on decision A, resolve A before raising B. Don't jump branches.

5. **Stress-test relationships with concrete scenarios.** When the user
   describes how concepts relate, invent specific scenarios that probe the
   boundary: "A customer cancels mid-fulfillment — does that touch the
   Invoice or only the Shipment?"

6. **Cross-reference statements against code.** When the user states how
   something works, sample the code. If the code disagrees, surface the
   contradiction immediately.

7. **Know when to stop.** When the remaining questions are details that
   implementation will answer faster than discussion, stop and write up what
   you have. Endless grilling is its own failure mode.

## What to Sharpen

During the session, keep three things sharp:

### Vocabulary

When the user uses a vague or overloaded term, propose a precise canonical
term. Cross-check against `docs/CONTEXT.md` if it exists. Conflicts with the
existing glossary must be called out — never silently re-define a term.

When you and the user agree on a term that isn't already documented, delegate
to the `domain-language` skill to draft it (drafts go into the active plan
directory; see `plan-driven-dev`).

### Decisions

When a discussion produces a decision, apply the ADR three-tests gate (see the
`adr` skill): hard-to-reverse + surprising-without-context + real-trade-off.
Only when all three pass should you offer to record the decision as an ADR.
Most decisions don't qualify; most that do, do so quietly.

### Behaviour

When discussing what to build, push for *observable behaviours through public
interfaces*, not implementation steps. "When the user clicks retry, the
delivery is queued again with the same payload" is a behaviour. "Add a retry
button that calls `enqueueRetry()`" is implementation.

This matters because behaviours map directly to vertical slices in
plan-implementation, and to tests in TDD. See the `tdd` skill.

## Output

A grilling session has a single deliverable: a clearer shared understanding,
captured in writing. Depending on context this lands in:

- `plan.md` — when grilling during `/plan`
- `<plan-dir>/drafts/context/` and `<plan-dir>/drafts/adr/` — for terms and
  decisions surfaced mid-session
- The conversation itself — when grilling outside a plan context

Never end a grilling session without summarising what was decided. Unwritten
agreements drift.
