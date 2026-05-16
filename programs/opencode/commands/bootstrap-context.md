---
description: Reverse-engineer a domain glossary from the codebase and write docs/CONTEXT.md
---

Load the `domain-language`, `grill`, and `work` skills.

This command bootstraps `docs/CONTEXT.md` for a repo that doesn't have one
(or has a stale one). It scans the codebase and existing docs for term
candidates, presents them one at a time with supporting evidence, and
writes accepted terms incrementally to `docs/CONTEXT.md`.

This is a free-standing command — it does **not** require an active plan
and does not write into a plan directory. Per the `domain-language`
skill's draft+promote rules, terms surfaced *during* a plan should go
through `/plan` instead, so they land alongside the change that
introduces them.

## Pre-flight

1. Verify the jj staging area is set up. If not, set it up per the `work`
   skill. Use a work commit message like:

   ```
   docs(context): bootstrap domain glossary
   ```

## Survey

2. Use the `explore` subagent (@explore) to walk the repository. Surface
   candidate terms from:

   - **Package / module names** — top-level directories, package
     declarations
   - **Exported types and interfaces** — structs, classes, interfaces
     visible at module boundaries
   - **Recurring identifiers** — names that appear in many places across
     the codebase
   - **README, CHANGELOG, and existing docs** — concepts already named
     in prose
   - **Database schema** — table and column names if accessible
   - **API surface** — endpoint paths, RPC method names, event names

   For each candidate, note where it appears (file paths and line refs).

3. Cluster candidates:

   - Group near-synonyms (e.g. `User`, `Account`, `Member` may be the
     same concept under different names).
   - Flag ambiguities (the same word used for different concepts in
     different parts of the code).
   - Drop candidates that are clearly general programming concepts
     (`Logger`, `Cache`, `Retry`, `Config`) and not domain-meaningful.

4. Read the project README (if present) to identify the lead-paragraph
   description for `docs/CONTEXT.md`.

## Confirm Per Term

5. Present each candidate term to the user, one at a time, in a
   consistent format:

   ```
   Candidate: **Customer**

   Proposed definition:
   A person or organisation that places Orders.

   Aliases observed in code (recommend rejecting these):
     - User (used in pkg/auth/, but means the login identity)
     - Account (used in pkg/billing/, but means a billing relationship)

   Evidence:
     - pkg/orders/customer.go:12 (type Customer struct)
     - pkg/orders/repo.go:34 (CustomerID field on Order)
     - README.md:18 ("Customers place orders for...")

   Accept this term? [y / refine / skip]
   ```

   Apply the rules from the `domain-language` skill:

   - Domain-meaningful only (would a non-engineer recognise it?)
   - One-sentence definition (what it IS, not what it does)
   - Be opinionated about aliases

   On `refine`, drop into a short grilling session using the `grill`
   skill: walk the user through the disagreement one question at a
   time, propose a revised entry, then re-present.

   On `skip`, drop the candidate but note it in a "Skipped" list for
   the final report.

## Write Incrementally

6. As terms are accepted, write them into `docs/CONTEXT.md` using the
   format from the `domain-language` skill's
   `references/context-format.md`. Create the file lazily on the first
   accepted term.

   - Lead paragraph from the README pass (or interview the user if the
     README doesn't supply one).
   - Language section: one entry per accepted term, alphabetical or
     grouped under sub-headings if natural clusters emerged.
   - Relationships section: populate as relationships surface during
     confirmation.
   - Flagged ambiguities: capture any conflicts identified during
     clustering.

   Updating the file term-by-term means the user can stop the session
   at any point and still have a useful glossary.

## Final Report

7. After the survey is complete, present a summary:

   - Terms added (count + list)
   - Candidates skipped (with reason)
   - Unresolved ambiguities that need follow-up
   - Suggested next steps (e.g. "consider running `/bootstrap-adrs`
     next")

8. The new `docs/CONTEXT.md` is in the working copy. Prompt the user to
   squash it into the work commit when ready, or do so on confirmation:

   ```bash
   jj squash docs/CONTEXT.md
   ```
