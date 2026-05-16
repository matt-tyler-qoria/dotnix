# CONTEXT.md Format Reference

The canonical layout for `docs/CONTEXT.md`. Use this template verbatim when
creating the file for the first time, and follow the rules below when adding
or amending entries.

## Template

```md
# {Project Name} — Context

{One or two sentences describing what this project does, in domain terms.
Avoid implementation language. A non-engineer reading this should understand
what the project is for.}

## Language

**Order**:
A request from a Customer to receive a set of Products.
_Avoid_: purchase, transaction, basket

**Invoice**:
A request for payment sent to a Customer after fulfilment.
_Avoid_: bill, payment request

**Customer**:
A person or organisation that places Orders.
_Avoid_: client, buyer, account, user

## Relationships

- A **Customer** places one or more **Orders**
- An **Order** produces one or more **Invoices**
- An **Invoice** belongs to exactly one **Customer**

## Example dialogue

> **Dev:** "When a **Customer** places an **Order**, do we create the
> **Invoice** immediately?"
>
> **Domain expert:** "No — an **Invoice** is generated once a **Fulfilment**
> is confirmed."

## Flagged ambiguities

- "account" was used to mean both **Customer** and **User** — resolved:
  these are distinct concepts. **User** is the login identity; **Customer**
  is the commercial relationship.
```

## Section Rules

### Header

`# {Project Name} — Context`. The em-dash and `Context` suffix make the
file's purpose obvious in search results.

### Lead paragraph

One or two sentences. Domain terms only. Avoid implementation words like
"service", "API", "database". This paragraph is what someone reads to find
out whether they're looking at the right document.

### Language

The body of the glossary. Group terms under sub-headings (`### Customers`,
`### Fulfilment`) only if natural clusters emerge — a flat list is fine for
small projects.

Each entry follows this exact format:

```md
**TermName**:
One sentence. What it IS, not what it does.
_Avoid_: alias-1, alias-2
```

- The term name is bold and ends with a colon.
- The definition starts on the next line.
- The `_Avoid_` line is omitted only when there are genuinely no alternative
  words people use.

### Relationships

Bullet list. Use bold for terms. Express cardinality where it isn't obvious.

```md
- A **Customer** places one or more **Orders**
- An **Order** produces one or more **Invoices**
```

Skip this section if the project has no meaningful relationships yet.

### Example dialogue

Optional but high-value. A short conversation between a developer and a
domain expert that demonstrates the terms working together. Useful for
catching cases where definitions look fine in isolation but trip over each
other in use.

### Flagged ambiguities

Place to record terms that were previously used in conflicting ways, and
the resolution. This is not a backlog — entries here are resolved decisions,
not open questions.

```md
- "X" was used to mean both **Y** and **Z** — resolved: ...
```

## What Belongs

Include:

- Domain entities (Customer, Order, Invoice)
- Domain processes (Fulfilment, Cancellation, Settlement)
- Domain roles (Buyer, Approver, Auditor)
- Project-specific status values when they carry meaning (e.g. `Settled`
  vs `Paid` if those are different)
- Project-specific units, identifiers, or money concepts

Exclude:

- Generic programming concepts (cache, retry, timeout, logger, queue) —
  unless the project uses them as load-bearing domain terms
- Implementation types (DTOs, controllers, repositories)
- Infrastructure (database names, service names, framework concepts)
- Words that mean the same in your project as everywhere else

The bar: would a non-engineer domain expert recognise this term? If not,
it doesn't belong.
