---
description: Execute the next step from the implementation plan
---

Load the `plan-driven-dev`, `work`, `domain-language`, `adr`, and `tdd`
skills.

## Pre-flight

1. Resolve the active plan directory:
   - If `$1` is provided, use it. Otherwise read `.active-plan`.
   - If neither is available, report an error and stop.

2. Verify the jj staging area is set up. Run `jj log --limit 3` and check:
   - `@` must be a staging area commit (description contains "staging area")
   - `@-` must be a work commit with a proper commit message
   If either is missing, set them up per the `work` skill before proceeding.

## Read

3. Read `plan.md`, `plan-implementation.md`, and `task-log.md` from the
   plan directory.

4. Using `task-log.md`, determine the next incomplete step from the
   implementation plan. Only complete **one** step per invocation.

5. Note any `_Promotes_:` entries on the chosen step. These are the
   draft files that must be promoted after implementation.

## Work Commit

6. Before writing any code, check whether `@-`'s commit message matches
   the step you are about to implement. If it does not, create a NEW work
   commit for this step (insert it between the staging area and the
   previous work commit per the `work` skill pre-flight checklist).

## Implement

7. Implement the step using the TDD loop from the `tdd` skill:
   - **RED**: write the one test that captures this step's behaviour.
     Run it. Confirm it fails for the right reason.
   - **GREEN**: write the minimal code that makes the test pass. Do not
     anticipate future steps.
   - **REFACTOR** (only if GREEN): clean up duplication, naming, or
     deepening opportunities. Re-run tests after each change.

   For non-code steps, implement the change as specified by the step.

## Verify

8. Invoke the `verify` subagent (@verify) to run build, lint, and tests
   on the changes. If verification fails, attempt to fix the issues.
   Re-run verification after fixes. If it still fails after two attempts,
   log the failure and stop.

## Promote Drafts

9. **Strict promotion**: only promote draft files explicitly listed under
   the step's `_Promotes_:` notes. Do not scan `drafts/` for unlisted
   files; surprise promotions are forbidden.

   For each listed draft:

   - **Context terms** (`<plan-dir>/drafts/context/<slug>.md`):
     - If `docs/CONTEXT.md` does not exist, create it using the template
       from the `domain-language` skill's `references/context-format.md`.
     - Merge the drafted entry into the Language section in the
       appropriate position (alphabetical, or inside the matching
       sub-heading group). Preserve formatting (`**Term**:`, definition,
       `_Avoid_:` line).
     - If the term introduces a new relationship and the draft includes
       one, append it to the Relationships section.
     - Delete the draft file.

   - **ADRs** (`<plan-dir>/drafts/adr/<slug>.md`):
     - If `docs/adr/` does not exist, create it.
     - Scan `docs/adr/` for the highest existing 4-digit prefix; the new
       ADR's number is highest+1 (zero-padded to four digits).
     - Move the draft to `docs/adr/NNNN-<slug>.md`.
     - Delete the draft file.

   Record the list of promoted files; they will be included in the task
   log entry and the squash.

## Log

10. Record the step's completion in `task-log.md` using the format
    defined in the `plan-driven-dev` skill. Include verification results
    and the list of promoted files (or "none").

## Squash

11. Selectively squash code and promoted `docs/` files into `@-`:
    - Find all plan directories (dirs containing `plan.md`).
    - Run `jj diff --name-only` to list changed files.
    - Squash everything **except** files inside any plan directory and
      `.active-plan`. Promoted `docs/CONTEXT.md` and `docs/adr/` files
      are squashed normally — they live outside the plan directory.
    - Run `jj st` to verify the staging area still exists and plan files
      remain in `@`.
