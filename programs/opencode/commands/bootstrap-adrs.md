---
description: Reverse-engineer Architecture Decision Records from the codebase and write docs/adr/
---

Load the `adr`, `grill`, and `work` skills.

This command bootstraps `docs/adr/` for a repo that doesn't have one. It
surveys the codebase for hard-to-reverse decisions visible in the
architecture, filters candidates through the three-tests gate, and
presents each one for confirmation before writing.

This is a free-standing command — it does **not** require an active plan
and does not write into a plan directory. Per the `adr` skill's
draft+promote rules, decisions surfaced *during* a plan should go through
`/plan` instead, so they land alongside the change that ratifies them.

If `docs/CONTEXT.md` does not yet exist, consider running
`/bootstrap-context` first — the glossary makes the ADR titles and bodies
read more sharply.

## Pre-flight

1. Verify the jj staging area is set up. If not, set it up per the `work`
   skill. Use a work commit message like:

   ```
   docs(adr): bootstrap architecture decision records
   ```

## Survey

2. Use the `explore` subagent (@explore) to walk the repository looking
   for **decisions worth recording**. Sources to inspect:

   - **Top-level architecture**
     - Monorepo vs polyrepo
     - Primary language(s) and framework(s)
     - Service / module decomposition

   - **Datastores and infrastructure**
     - Database choice (visible in dependencies, configs, schema files)
     - Message bus, cache, search, queue technology
     - Auth provider, deployment target

   - **Module boundaries**
     - What's split into separate packages/services and why
     - Cross-boundary contracts (events, RPC schemas, shared types)
     - Things deliberately *not* split (interesting in their own right)

   - **Deliberate deviations**
     - Manual SQL where an ORM is present (or vice versa)
     - Custom protocols where standards exist
     - Hand-rolled retry / pooling / serialization where libraries are
       in scope
     - Non-default configuration of major dependencies

   - **Constraints visible from configs**
     - CI configurations (forbidden providers, required compliance
       checks)
     - Comments mentioning "we can't use X because…"
     - Deprecation notices

   - **Existing prose**
     - README sections explaining "why we chose X"
     - Design docs in `docs/`
     - Long-form code comments documenting non-obvious choices

   For each candidate decision, capture:

   - A draft title
   - The supporting evidence (file paths, configs, dependencies)
   - The apparent rationale (from code, comments, or absence of
     alternatives)

## Filter Through The Three-Tests Gate

3. Apply the `adr` skill's three-tests gate to each candidate. Drop
   anything that fails:

   1. **Hard to reverse** — the cost of changing your mind is
      meaningful.
   2. **Surprising without context** — a future reader would wonder
      "why did they do it this way?"
   3. **The result of a real trade-off** — there were genuine
      alternatives.

   Be ruthless. A bloated ADR set is noise; a sparse one is signal.
   Skipped candidates can be mentioned in the final report so the user
   can revisit if they disagree.

## Confirm Per ADR

4. Present each surviving candidate to the user, one at a time:

   ```
   Candidate ADR: Postgres for the write model

   Proposed body:
   We use PostgreSQL as the durable store for the order write model
   because we need transactional guarantees across the order, line-items,
   and audit-log tables, and the team already operates Postgres at scale.

   Three-tests gate:
     - Hard to reverse:  YES (data migration)
     - Surprising:       YES (team came from a Mongo background)
     - Real trade-off:   YES (Postgres vs Dynamo vs EventStoreDB)

   Evidence:
     - go.mod:14         (github.com/jackc/pgx/v5)
     - migrations/0001_create_orders.sql
     - README.md:42      ("we chose Postgres because…")
     - pkg/orders/repo.go:22 (uses transactions across multiple tables)

   Suggested status: accepted (omit frontmatter)

   Accept this ADR? [y / refine / skip]
   ```

   Apply the rules from the `adr` skill:

   - 1–3 sentences for the body unless an optional section is genuinely
     warranted.
   - Optional sections only when they earn their keep (rejected
     alternatives worth remembering, non-obvious downstream consequences).
   - Status frontmatter only when not plain `accepted`.

   On `refine`, drop into a short grilling session with the `grill`
   skill: walk through the disagreement one question at a time, propose
   a revised ADR, then re-present.

   On `skip`, drop the candidate. Note it in a "Skipped" list for the
   final report with the reason.

## Write Incrementally

5. As ADRs are accepted, write them into `docs/adr/`:

   - Create `docs/adr/` lazily on the first accepted ADR.
   - Slug the title (lowercase, hyphenated, drop articles, under 60
     characters).
   - Number sequentially starting from `0001`. The order in which you
     present candidates determines numbering, so present in a sensible
     order (foundational decisions first: monorepo shape, primary
     datastore, etc., then narrower ones).

   Updating one ADR at a time means the user can stop the session at
   any point and still have a useful set.

## Final Report

6. After the survey is complete, present a summary:

   - ADRs added (count + numbered list)
   - Candidates skipped at the three-tests gate (with the test that
     failed)
   - Candidates skipped by user choice (with reason if given)
   - Suggested next steps (e.g. "the auth provider choice looks
     ADR-worthy but the rationale isn't visible in the repo — capture
     it as a follow-up via `/adr` after you've confirmed the rationale
     with the team")

7. The new files in `docs/adr/` are in the working copy. Prompt the user
   to squash them into the work commit when ready, or do so on
   confirmation:

   ```bash
   jj squash docs/adr/
   ```
