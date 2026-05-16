# ADR Examples

Worked examples of decisions that pass and fail the three-tests gate, and
sample ADRs in the canonical format.

## Decisions That Pass The Gate

### Architectural shape

> "We're using a monorepo for all backend services."

- Hard to reverse: yes, splitting later is painful.
- Surprising: maybe — depends on the org's history. If the team came
  from a polyrepo background, yes.
- Real trade-off: yes — atomic cross-service changes vs build-tool
  complexity.

**ADR-worthy.**

### Technology with lock-in

> "We chose PostgreSQL for the write model."

- Hard to reverse: yes, data migration is a project of its own.
- Surprising: only if the obvious choice for this team was something
  else (e.g. Dynamo, Mongo, an event store). Decide based on the team.
- Real trade-off: yes — transactional guarantees vs operational
  surface vs scaling characteristics.

**ADR-worthy.**

### Boundary

> "Customer data is owned by the Customer context. Other contexts
> reference it by ID only and never join across the boundary."

- Hard to reverse: yes — once contexts join freely, untangling them is
  expensive.
- Surprising: yes — a future engineer adding a feature will be tempted
  to join the data directly.
- Real trade-off: yes — per-context encapsulation vs cross-context
  query performance.

**ADR-worthy.**

### Deliberate deviation

> "We use raw SQL for read queries instead of the ORM."

- Hard to reverse: medium — the codebase grows around the choice.
- Surprising: yes — a reasonable reader will ask "why aren't we using
  the ORM?" and propose to "fix" it.
- Real trade-off: yes — query control vs boilerplate.

**ADR-worthy.** This is a classic case where the ADR's value is
preventing the next engineer from undoing a deliberate choice.

### Constraint

> "We can't use any AWS service because of compliance requirements."

- Hard to reverse: yes (the constraint is external).
- Surprising: yes if the team would otherwise default to AWS.
- Real trade-off: yes — picking around the constraint shapes
  architecture.

**ADR-worthy.** Constraints not visible in code are exactly what ADRs
exist to record.

## Decisions That Fail The Gate

### Trivially reversible

> "We named the rate-limit middleware `rateLimit` instead of `throttle`."

- Hard to reverse: no, rename is one commit.

**Not an ADR.** Just rename it if you change your mind.

### Obvious default

> "We use HTTPS for all external requests."

- Surprising: no, this is the obvious default.

**Not an ADR.** Nothing to explain.

### No real alternative

> "We use the team's mandated CI provider."

- Real trade-off: no, there was no choice.

**Not an ADR.** "We did the only thing we could" is not a record worth
keeping.

### Implementation detail

> "The retry function uses exponential backoff with full jitter."

- Hard to reverse: no — algorithm change is a small refactor.
- Surprising: not really — this is a known good default.
- Real trade-off: maybe, but the trade-off lives in code comments
  alongside the implementation, not in `docs/adr/`.

**Not an ADR.** Decisions about *how* code works belong with the code.

## Sample ADRs

### Single-paragraph (the most common shape)

```md
# Postgres for the write model

We chose PostgreSQL as the durable store for the order write model
because we need transactional guarantees across the order, line-items,
and audit-log tables, and the team already operates Postgres at scale.
DynamoDB and EventStoreDB were considered and rejected: Dynamo's
conditional writes are not strong enough for our multi-table invariants,
and EventStoreDB adds an operational surface area we are not ready to
take on.
```

### With status frontmatter

```md
---
status: accepted
---

# Outbound HTTP routes through the shared httpx client

All outbound HTTP from any service must go through the `httpx` client in
`pkg/httpx`. This centralises retry, timeout, observability, and TLS
policy. Direct use of `net/http.Client` for outbound calls is forbidden
outside `pkg/httpx`.
```

### Superseded

```md
---
status: superseded by ADR-0021
---

# Use Redis for session storage

We use Redis to store user session state because we need sub-millisecond
read latency and shared state across the API fleet.
```

(ADR-0021 would explain the move to Postgres-backed sessions, why the
latency requirement changed, and what Redis was good and bad at.)

### Deprecated

```md
---
status: deprecated
---

# Cron job for daily settlement

A cron job runs at 02:00 UTC to settle the day's transactions.

**Deprecated:** the settlement system was replaced by the streaming
ledger in 2024-Q3 (see ADR-0034). The cron job no longer exists.
```
