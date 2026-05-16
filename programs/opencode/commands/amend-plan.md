---
description: Amend the implementation plan based on review findings
---

Load the `plan-driven-dev` and `work` skills.

Resolve the active plan directory:
- If the last positional argument is a directory containing `plan.md`, use it.
- Otherwise read `.active-plan`.
- If neither is available, report an error and stop.

Read the following files from the resolved plan directory:
- plan.md
- plan-implementation.md
- task-log.md

## Identify Issues

If `$ARGUMENTS` contains specific issues or feedback, use those as the basis
for amendments.

If no specific issues are provided, perform the same analysis as `/review-plan`:
identify gaps, deviations, and unaddressed concerns in the remaining steps.

## Propose Amendments

For each issue identified:

1. Determine which future (incomplete) steps are affected.
2. Propose specific changes:
   - Modify an existing step's description or acceptance criteria
   - Insert new steps (use sub-numbering like 5a, 5b or renumber)
   - Remove steps that are no longer needed
   - Reorder steps if dependencies have changed

**Never amend completed steps.** Only modify future/incomplete steps.

## Confirm and Apply

Present the proposed amendments as a clear summary showing what will change in
`plan-implementation.md`:

```
Step 5: (unchanged)
Step 6: MODIFIED — added handling for 408 timeout responses
Step 6a: NEW — add Retry-After header parsing
Step 7: (renumbered from 6, unchanged)
```

Explain the rationale for each change.

**Wait for the user to confirm** before writing any changes. If the user
requests modifications to the proposal, revise and present again.

Once confirmed, update `plan-implementation.md` with the amendments.
