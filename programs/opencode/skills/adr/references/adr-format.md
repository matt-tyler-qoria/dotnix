# ADR Format Reference

Architecture Decision Records live in `docs/adr/` and follow MADR-lite:
small, opinionated, and easy to write.

## Filename

`docs/adr/NNNN-slug.md`

- `NNNN` — 4-digit zero-padded sequential number (`0001`, `0002`, ...).
  Scan `docs/adr/` for the highest existing number and increment by one.
- `slug` — lowercase hyphenated form of the title. Drop articles ("a",
  "the") and punctuation. Keep under 60 characters.

Examples:

- `0001-event-sourced-orders.md`
- `0007-postgres-for-write-model.md`
- `0014-no-graphql-rest-only.md`

## Minimum Template

```md
# {Short title of the decision}

{1–3 sentences. Capture the context, the decision, and why we chose it
over the alternatives. That is enough.}
```

That's a complete ADR. The value is in *that* the decision was recorded
and *why* — not in filling in headings.

## With Optional Sections

Add sections only when they earn their keep. Most ADRs do not need them.

```md
---
status: accepted
---

# Postgres for the write model

We chose PostgreSQL as the durable store for the order write model
because we need transactional guarantees across the order, line-items,
and audit-log tables, and the team already operates Postgres at scale.

## Considered Options

- **PostgreSQL** — chosen. Strong transactions, team familiarity.
- **DynamoDB** — rejected. Conditional-write semantics are not enough
  for the multi-table invariants we need.
- **Event store (EventStoreDB)** — rejected. Adds an operational
  surface area we are not ready to take on.

## Consequences

- Schema migrations must coexist with online traffic; we will need to
  adopt expand/contract migrations.
- Read model is projected separately (see ADR-0008).
```

## Frontmatter

Use frontmatter only when status matters. Skip it for plain `accepted` ADRs
that are unlikely to change.

```yaml
---
status: proposed | accepted | deprecated | superseded by ADR-NNNN
---
```

- **proposed** — drafted but not yet ratified. Rare; usually only used by
  `/bootstrap-adrs` for candidate decisions awaiting user confirmation.
- **accepted** — the default state. Omit frontmatter when this is the case.
- **deprecated** — the decision is no longer relevant (e.g. the component
  it described was removed). Add a one-line note explaining why.
- **superseded by ADR-NNNN** — the decision was overturned by a later
  ADR. Body of the original is left intact; supersession note links the
  replacement.

## What to Capture in the Body

In the 1–3 sentences:

- **Context** — what situation forced the decision. One phrase, not a
  history lesson.
- **Decision** — what we chose. State it plainly.
- **Why** — the load-bearing reason. The one sentence a future reader
  needs to stop themselves from "fixing" the choice.

Skip anything a reader can find by reading the code. ADRs explain
*intent*, not implementation.

## When to Use Each Optional Section

### Considered Options

Include when:

- The chosen option looks worse on the surface than a rejected one
- A reasonable reader would propose the rejected option six months from
  now
- The trade-offs are subtle enough that you'll forget them yourself

Format:

- One bullet per option.
- Bold the option name.
- Mark which was chosen and why each was rejected.

### Consequences

Include when downstream effects are non-obvious. Examples:

- Forces a particular migration strategy
- Constrains a future technology choice
- Requires operational changes (monitoring, runbooks)
- Imposes a contract on a downstream system

Skip when consequences are obvious from the decision itself.

## Anti-patterns

- **ADRs for trivial decisions.** "We named the function `processOrder`
  instead of `handleOrder`" is not an ADR. Apply the three tests.
- **ADRs as design documents.** ADRs are *records*, not designs. Do the
  design work in the plan; capture the result in the ADR.
- **Editing accepted ADRs.** Once an ADR is accepted, the body is
  immutable. To change a decision, write a new ADR and supersede the
  old one.
- **Vague rationale.** "We chose X because it's better" is useless. Name
  the specific trade-off you optimised for.
- **Listing every option ever discussed.** Considered Options should
  contain only the alternatives that were genuine contenders.
