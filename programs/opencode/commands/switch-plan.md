---
description: Switch the active plan to a different plan directory
---

Load the `plan-driven-dev` skill.

If `$1` is provided, verify that `$1/plan.md` exists. If it does, write `$1`
to `.active-plan` and confirm the switch. If it does not exist, report an error.

If `$1` is not provided:
1. Search for all directories in the project that contain a `plan.md` file.
2. List them with their current progress (count completed vs total steps from
   each `plan-implementation.md`).
3. Ask the user which plan to switch to.
4. Write the selected directory to `.active-plan`.

After switching, show the `task-log.md` summary for the newly active plan so
the user has context on where they left off.
