---
description: Add or amend a single term in docs/CONTEXT.md outside of any plan
---

Load the `domain-language`, `grill`, and `work` skills.

This command captures a single domain term directly into `docs/CONTEXT.md`,
bypassing the plan-driven draft+promote flow. Use it for retroactive
cleanup, not for terms that arise from in-flight plan work — those should
go through `/plan` so the term lands alongside the change that introduces
it.

## Pre-flight

1. Verify the jj staging area is set up. If not, set it up per the `work`
   skill. Use a work commit message like:

   ```
   docs(context): add <term> to glossary
   ```

   or

   ```
   docs(context): refine <term>
   ```

## Identify the Term

2. Take the term from `$ARGUMENTS`. If none provided, ask the user which
   term they want to add or amend.

3. Read `docs/CONTEXT.md` if it exists. Check whether the term is already
   present:

   - **New term** — proceed to drafting.
   - **Existing term** — show the current entry and ask what should
     change. Treat amendments carefully: if the meaning is shifting, add
     a `Flagged ambiguities` note recording the change.

## Draft the Entry

4. Use the `grill` skill to interview the user on:

   - The single-sentence definition (what it IS, not what it does)
   - Aliases people use that should be rejected (`_Avoid_:` line)
   - Any new relationships this term participates in

   For each question, propose a recommended answer. Cross-check the
   proposed definition against the codebase — if the code suggests a
   different meaning, surface the conflict.

## Apply

5. If `docs/CONTEXT.md` does not exist, create it using the template from
   the `domain-language` skill's `references/context-format.md`. Include
   the project name and a one-line lead paragraph.

6. Insert or update the entry in the Language section in the appropriate
   position (alphabetical, or inside the matching sub-heading group).
   Preserve existing formatting.

7. If a new relationship was identified, append it to the Relationships
   section (create the section if it does not exist).

8. If this amendment changes the meaning of an existing term, add a
   `Flagged ambiguities` entry recording the change.

## Confirm and Squash

9. Show the user the updated `docs/CONTEXT.md` excerpt (the changed
   region only).

10. After user confirmation, the change to `docs/CONTEXT.md` is part of
    the working copy. The user can squash it into the work commit when
    ready, or you can prompt to do so immediately:

    ```bash
    jj squash docs/CONTEXT.md
    ```
