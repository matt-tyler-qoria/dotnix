---
description: Review the last completed step against plan intent
agent: review
subtask: true
---

Load the `plan-driven-dev` skill and resolve the active plan directory.

If `$1` is provided, use it as the plan directory. Otherwise, read `.active-plan`.
If neither is available, report an error.

Read the following files from the resolved plan directory:
- plan.md
- plan-implementation.md
- task-log.md

Identify the most recently completed step from task-log.md and review its
implementation against the plan intent. Follow the review procedure defined in
your system prompt.

Do perform any implementation. Report findings only.
