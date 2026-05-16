---
description: Review implementation progress against the plan for conformance
---

Load the `plan-driven-dev` skill and resolve the active plan directory:
- If `$1` is provided, use it. Otherwise read `.active-plan`.
- If neither is available, report an error and stop.

Read the following files from the resolved plan directory:
- plan.md
- plan-implementation.md
- task-log.md

Using `task-log.md`, determine what steps have been completed so far. Note any
steps that logged issues, failures, or deviations.

Compare the plan's intent (from `plan.md`) with what was actually implemented
across all completed steps. Identify:

1. **Gaps** — things the plan requires that no step has addressed
2. **Deviations** — steps that implemented something different from the intent
3. **Patterns** — recurring issues across multiple steps (e.g. "steps 3-5 all
   underhandled error cases")

For each gap or deviation, check whether a future step in `plan-implementation.md`
already addresses it. Report only **unaddressed** issues.

Do NOT modify any files. This is a review-only command — report your findings
as output. If amendments are needed, recommend the user run `/amend-plan`.
