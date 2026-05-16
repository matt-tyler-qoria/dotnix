---
description: Execute multiple plan steps with verification and review
---

Load the `plan-driven-dev` and `work` skills.

Resolve the active plan directory:
- If `$2` is provided, use it. Otherwise read `.active-plan`.
- If neither is available, report an error and stop.

Determine the number of steps to execute:
- If `$1` is provided, use it as the count.
- If not provided, default to 1.

For each step (up to the count):

1. Execute the step using the same logic as the `/step` command:
   - Pre-flight check (jj staging area)
   - Read plan files, determine next step
   - Create work commit if needed
   - Implement the step
   - Invoke the `verify` subagent (@verify)

2. If verification fails after fix attempts, **stop** and report progress.

3. Invoke the `review` subagent (@review) to check plan-intent alignment for
   the just-completed step.

4. If the review reports **significant deviation**, **stop** and report. Suggest
   the user run `/amend-plan` if the plan needs updating, or fix the deviation
   manually.

5. If verification passes and review reports aligned or minor deviation, log the
   step in `task-log.md`, squash code into `@-`, and continue to the next step.

After all steps complete (or early stop), summarize:
- Steps completed: N of M requested
- Steps remaining in plan: X
- Any issues encountered
- Recommendation: continue, /review-plan, or /amend-plan
