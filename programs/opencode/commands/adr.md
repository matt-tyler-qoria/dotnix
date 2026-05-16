---
description: Capture a single Architecture Decision Record outside of any plan
---

Load the `adr`, `grill`, and `work` skills.

This command captures one ADR directly into `docs/adr/`, bypassing the
plan-driven draft+promote flow. Appropriate for retroactive capture of
decisions made before the plan-driven flow was adopted, or for decisions
that fall outside any active plan. For decisions that arise from in-flight
plan work, use `/plan` so the ADR is promoted alongside the step that
ratifies it.

## Pre-flight

1. Verify the jj staging area is set up. If not, set it up per the `work`
   skill. Use a work commit message like:

   ```
   docs(adr): record <short title>
   ```

## Three-Tests Gate

2. Apply the `adr` skill's three-tests gate to the decision the user
   wants to record:

   1. **Hard to reverse** — the cost of changing your mind later is
      meaningful.
   2. **Surprising without context** — a future reader will wonder
      "why did they do it this way?"
   3. **The result of a real trade-off** — there were genuine
      alternatives and you picked one for specific reasons.

   Walk through each test with the user. If any test fails, recommend
   skipping the ADR and explain why. Do not proceed unless all three
   pass.

   See `references/adr-examples.md` (in the `adr` skill) for worked
   examples.

## Draft

3. Use the `grill` skill to interview the user on:

   - **Title** — short, names the decision (not "we chose X", just "X").
   - **Context** — what situation forced the decision. One phrase.
   - **Decision** — what was chosen. State plainly.
   - **Why** — the load-bearing reason. The one sentence a future
     reader needs to stop themselves from "fixing" the choice.
   - **Considered Options** — only if the rejected alternatives are
     worth remembering and would otherwise be re-suggested.
   - **Consequences** — only if non-obvious downstream effects need
     calling out.
   - **Status** — usually `accepted`. Skip frontmatter when so. Use
     other values only if applicable (`proposed`, `deprecated`,
     `superseded by ADR-NNNN`).

   Propose recommended answers for each question.

## Number and Write

4. Determine the slug from the title: lowercase, hyphenated, drop
   articles and punctuation, under 60 characters.

5. Scan `docs/adr/` for the highest existing 4-digit prefix. The new
   ADR's number is highest+1, zero-padded to four digits. If `docs/adr/`
   does not exist, create it; the first ADR is `0001-<slug>.md`.

6. Write the ADR to `docs/adr/NNNN-<slug>.md` using the format from the
   `adr` skill's `references/adr-format.md`. Keep the body to 1–3
   sentences unless an optional section is genuinely warranted.

## Confirm and Squash

7. Show the user the written ADR file.

8. The new file is in the working copy. Prompt the user to squash it
   into the work commit when ready, or do so immediately on confirmation:

   ```bash
   jj squash docs/adr/NNNN-<slug>.md
   ```
