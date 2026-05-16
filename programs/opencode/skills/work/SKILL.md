---
name: work
description: Work conventions and workflow requirements. Must be loaded at the start of every session.
license: MIT
compatibility: opencode
---

## Commit Messages

Commits must follow the Conventional Commits specification with a Jira ticket ID prefix. Always load the `conventional-commits` skill before writing commit messages.

The Jira ticket ID is prepended before the conventional commit type.

Format: `<PROJECT>-<NUMBER>: <type>(<optional scope>): <description>`

Examples:
- `PLAT-567: feat(api): add retry logic to webhook handler`
- `INFRA-42: chore(deps): update Terraform provider versions`
- `DATA-99: fix: resolve null pointer in batch processor`
- `PLAT-567: docs(api): add webhook endpoint documentation`

With body and footer:
```
PLAT-567: feat(auth): add two-factor authentication

Add TOTP-based two-factor authentication to the login flow.
Users can enable 2FA from their account settings page.

Closes #456
```

The Jira project prefix varies by project. If you do not know the ticket ID, ask the user before committing.

## Commit Discipline

Every commit must be atomic, isolated, and testable. This is a hard requirement.

- **One logical change per commit.** Do not bundle unrelated changes together. A commit that adds a feature should not also fix a linter warning in an unrelated file.
- **Each commit must leave the codebase in a working state.** Tests should pass and the project should build after every individual commit, not just at the end of a series.
- **Prefer small, reviewable commits.** If a change is large, break it into a sequence of smaller commits that each make sense on their own. Each commit in the sequence should still be independently buildable and testable.
- **Separate refactoring from behavior changes.** If you need to restructure code before adding a feature, do the refactoring in one commit and the feature in the next.

When in doubt, err on the side of making commits too small rather than too large.

## Branch / Bookmark Naming

Branches and jj bookmarks must include the Jira ticket ID.

Format: `<PROJECT>-<NUMBER>-short-description`

Examples:
- `PLAT-567-webhook-retry`
- `INFRA-42-terraform-update`

## Jujutsu Staging Area Workflow

The user maintains a **staging area commit** at the head of the commit graph. This is the working copy (`@`). Its parent (`@-`) is the commit that represents the finished work.

```
@  (staging area — all work happens here, plan files live here)
○  (work commit — receives selectively squashed code changes)
○  main
```

### Pre-flight checklist (run before ANY code changes)

You MUST run this checklist before modifying any files. No exceptions.

1. Run `jj log --limit 3` and inspect the output.
2. **Check `@`**: Does the working copy commit have a description containing "staging area"?
   - **YES** → staging area exists, go to step 3.
   - **NO** → go to step 5.
3. **Check `@-`**: Does the parent commit have a proper work commit message (Jira ID + conventional commit type)?
   - **YES** → go to step 4.
   - **NO** → a work commit is needed. Go to step 5.
4. **Check `@-` matches the current task**: Does the `@-` commit message describe the work you are about to do?
   - **YES** → pre-flight complete. You may write code.
   - **NO** → `@-` is from a previous task. You need a NEW work commit. Insert one between the staging area and the old work commit:
     ```bash
     jj new @- && jj desc -m "PLAT-567: feat(api): add retry logic"
     jj rebase -r <staging-change-id> -d @
     jj edit <staging-change-id>
     ```
     Then re-run step 1 to verify.
5. **No staging area or no work commit.** Create both:
   ```bash
   # Create the work commit
   jj new && jj desc -m "PLAT-567: feat(api): add retry logic"

   # Create the staging area on top
   jj new && jj desc -m "staging area — do not commit"
   ```
   Then re-run step 1 to verify the graph looks like:
   ```
   @  staging area — do not commit
   ○  PLAT-567: feat(api): add retry logic
   ○  main
   ```

### How it works

1. **All work happens in `@` (the staging area).** Edit code, run tests, iterate — everything is done here. Plan files, scratch notes, and temporary content also live here.
2. **The parent commit (`@-`)** only receives finished code via selective squash. It represents the clean commit that will eventually be pushed.
3. When code changes are ready, selectively squash only the code files down to `@-`, keeping plan files in `@`:

```bash
# Squash specific files into the parent, keeping plan files in @
jj squash path/to/changed/file.go path/to/another.go
```

5. If all changed files are code (no plan files were modified), a plain `jj squash` is fine — but always verify first with `jj diff`.
6. **Never squash plan files** into the work commit. If you accidentally do, use `jj undo` to reverse it.

### Agent rules

- **Before squashing**, run `jj diff` to identify which files have changes. Only squash code files — never files inside plan directories (any directory containing `plan.md`) or `.active-plan`. See the `plan-driven-dev` skill for full conventions on plan file handling.
- **After squashing**, run `jj st` to verify the staging area still exists and plan files remain in `@`.
- **Do not abandon the staging area.** If `@` is empty after a squash, that is fine — it remains as the staging area for the next set of changes.
- When the user says "commit this" or "squash this down", they mean selectively squash code changes from `@` into `@-`, leaving plan files behind.
- When performing plan-driven development, load the `plan-driven-dev` skill for full conventions on plan file handling.

## Required Skills

- Always load the `conventional-commits` skill before writing commit messages.
- When working in a repository that contains a `.jj/` directory, always load the `jujutsu` skill before performing any VCS operations.
- When working in a repository that contains a `go.mod` file, load the following golang skills: `golang-repository-setup`, `golang-code-style`, `golang-data-structures`, `golang-database`, `golang-design-patterns`, `golang-documentation`, `golang-error-handling`, `golang-modernize`, `golang-naming`, `golang-safety`, `golang-testing`, `golang-troubleshooting`, `golang-security`.
- When working with CockroachDB (the project uses CockroachDB as a dependency, or SQL references CockroachDB-specific features), load the `designing-application-transactions` skill.
