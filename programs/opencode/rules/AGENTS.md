# Work Environment Rules

Always load the `work` skill at the start of every session before doing anything else.

## Jujutsu Pre-flight (mandatory)

Before modifying ANY files in a jj repository (one with a `.jj/` directory), you MUST run `jj log --limit 3` and verify:

1. A staging area commit exists at `@` (description contains "staging area")
2. A work commit exists at `@-` with a proper commit message
3. The `@-` commit message describes the work you are about to do — if it is from a previous task, create a NEW work commit before the staging area

If either is missing, set them up per the `work` skill BEFORE writing any code. Do NOT skip this check.
