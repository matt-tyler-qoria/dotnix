# Conventional Commit Examples

A comprehensive collection of commit message examples following the Conventional Commits specification.

## Features (feat)

### Simple Feature Addition

```
feat: add user profile page
```

### Feature with Scope

```
feat(auth): add two-factor authentication
```

### Feature with Body

```
feat(search): add semantic similarity search

Implement AI-based similarity detection between documents
to improve search relevance. Uses vector embeddings with
configurable similarity threshold.
```

### Feature with Issue Reference

```
feat(api): add webhook signature verification

Add HMAC-SHA256 signature verification for all incoming
webhooks from external services.

Closes #456
```

### Breaking Change Feature

```
feat(api)!: redesign authentication flow

BREAKING CHANGE: The authentication endpoint now requires
OAuth 2.0 instead of API keys. All clients must migrate
to the new OAuth flow.

Migration guide: docs/oauth-migration.md
```

## Bug Fixes (fix)

### Simple Bug Fix

```
fix: resolve login redirect loop
```

### Bug Fix with Scope

```
fix(api): handle null response from webhook
```

### Bug Fix with Detailed Explanation

```
fix(auth): resolve concurrent login race condition

Add pessimistic locking to prevent race condition when
multiple login attempts occur simultaneously for the
same user account.

The race condition could cause session data corruption
when two requests tried to update the user's last_login_at
timestamp at the same time.

Fixes #789
```

## Documentation (docs)

### Simple Documentation Update

```
docs: update README with setup instructions
```

### Comprehensive Documentation

```
docs(contributing): add code review guidelines

Add detailed guidelines for code reviewers covering:
- Security review checklist
- Performance considerations
- Test coverage requirements
- Commit message standards

Related to #234
```

## Refactoring (refactor)

### Simple Refactoring

```
refactor: extract validation logic to service
```

### Large Refactoring

```
refactor(services): migrate to Result pattern

Convert all service objects to return explicit Result
objects instead of raising exceptions for control flow.

This improves error handling consistency and makes
service behavior more predictable.

No behavior changes - pure refactoring.
```

## Performance (perf)

### Simple Performance Improvement

```
perf: add database index for user lookups
```

### Performance with Details

```
perf(queries): eliminate N+1 queries in artifacts index

Add eager loading for associated records when fetching
artifacts. Reduces database queries from ~500 to 3 for
a typical page load.

Before: 2.3s page load time
After: 0.3s page load time
```

## Tests (test)

### Simple Test Addition

```
test: add specs for user authentication
```

### Comprehensive Test Suite

```
test(services): add complete coverage for CreateOrderService

Add unit tests covering:
- Successful order creation
- Validation failures
- Payment processing errors
- Inventory reservation edge cases
- Concurrent order handling

Increases coverage from 67% to 95%.
```

## Chores (chore)

### Dependency Update

```
chore(deps): bump rails from 7.1.0 to 7.2.0
```

### Maintenance Work

```
chore(ci): add security scanning to GitHub Actions

Add Brakeman security scanning and bundler-audit to
the CI pipeline. Scans run on every PR and main branch push.
```

## Revert (revert)

### Revert with Explanation

```
revert: revert "perf: add caching layer"

This reverts commit a1b2c3d4.

The caching implementation caused data inconsistency issues
in multi-tenant environments. Reverting until we can implement
tenant-aware cache invalidation.

Related to #567
```

## Anti-Patterns (Avoid These)

### Bad

```
fix: update stuff                                    # Vague
feat: added user profile                             # Past tense
Feat: Add user profile                               # Capitalized
feat: add user profile.                              # Trailing period
feat: add a really comprehensive user profile page   # Too long
feat: add profile, fix login, update README          # Multiple changes
add user profile                                     # Missing type
```

### Good

```
feat: add user profile
fix: resolve login bug
docs: update README with setup instructions
refactor: optimize database queries
```

## Quick Reference

**Basic Format:**
```
<type>(<scope>): <description>
```

**Common Types:**
- `feat:` New feature
- `fix:` Bug fix
- `docs:` Documentation
- `style:` Formatting
- `refactor:` Refactoring
- `perf:` Performance
- `test:` Tests
- `chore:` Maintenance

**Breaking Changes:**
```
feat!: change API
# or
BREAKING CHANGE: footer
```

**Issue References:**
```
Closes #123
Fixes #456
Related to #789
```
