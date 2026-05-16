---
description: Selectively squash code changes into the work commit, excluding all plan files
---

Load the `plan-driven-dev` and `work` skills.

## Procedure

1. Run `jj diff --name-only` to list all changed files in the staging area (`@`).

2. If there are no changes, report "nothing to squash" and stop.

3. Identify plan files to exclude:
   - Find all directories in the project that contain a `plan.md` file (these
     are plan directories).
   - Any changed file whose path is inside a plan directory is a plan file.
   - `.active-plan` is also a plan file.

4. Separate changed files into two lists:
   - **Code files** — to be squashed into `@-`
   - **Plan files** — to be kept in `@`

5. Show both lists to the user:
   ```
   Will squash into @-:
     src/webhook/retry.go
     src/webhook/retry_test.go

   Will keep in @:
     webhook-retry/task-log.md
     .active-plan
   ```

6. Squash the code files: `jj squash <code-file-1> <code-file-2> ...`

7. Run `jj st` to verify the staging area still exists and plan files remain.

8. Report the result.

If no code files are found (all changes are plan files), report "only plan files
changed — nothing to squash" and stop.
