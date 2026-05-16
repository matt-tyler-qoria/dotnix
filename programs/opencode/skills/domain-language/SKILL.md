---
name: domain-language
description: Capture and maintain the project's ubiquitous language in docs/CONTEXT.md. Use when introducing a new domain term, sharpening a fuzzy one, resolving alias conflicts, or when grilling surfaces concepts that need precise definitions. Drafts terms inside the active plan directory; promotion to docs/CONTEXT.md happens when the ratifying step completes.
license: MIT
compatibility: opencode
---

# Domain Language

Maintain a shared vocabulary between the user, the codebase, and the agent.
The vocabulary lives in `docs/CONTEXT.md`. Every concept that is meaningful
to the domain (not just to the implementation) gets one entry.

A good ubiquitous language pays for itself every session: variables, files,
test names, and conversations all collapse onto the same words. Misalignment
between code and conversation is the single largest source of waste in
software work.

## File Location

- **Single context (default):** `docs/CONTEXT.md`
- **Multi-context (deferred):** if a project grows multiple bounded contexts,
  introduce `docs/CONTEXT-MAP.md` listing the contexts and their per-context
  `CONTEXT.md` files. Not part of the default flow — only adopt when the
  project genuinely needs it.

Create `docs/CONTEXT.md` lazily — only when the first term is ratified. Do
not commit empty scaffolding.

## Format

See `references/context-format.md` for the full canonical template. The
short version:

```md
# {Project Name} — Context

{One or two sentences describing what this project does, in domain terms.}

## Language

**Term**:
{One-sentence definition. What it IS, not what it does.}
_Avoid_: rejected-alias-1, rejected-alias-2

## Relationships

- A **Term-A** has many **Term-B**s
- A **Term-B** belongs to exactly one **Term-A**

## Flagged ambiguities

- "foo" was used to mean both **Bar** and **Baz** — resolved: distinct concepts.
```

## Rules

1. **Only domain-meaningful terms.** General programming concepts (timeouts,
   loggers, caches, retries) do not belong, even if the project uses them
   constantly. Ask: would a non-engineer domain expert recognise this concept?
   If no, it belongs in code comments, not `CONTEXT.md`.

2. **Be opinionated about aliases.** When multiple words exist for one
   concept, pick the canonical word and list the others under `_Avoid_`. Half
   a glossary is naming the loser.

3. **One sentence per definition.** Define what the term IS. Behaviour
   belongs in code or ADRs, not the glossary.

4. **Bold every term reference.** In Relationships, dialogue examples, and
   ambiguity notes, write `**Term**` so readers can see at a glance which
   words are load-bearing.

5. **Flag conflicts explicitly.** When a term is used ambiguously, capture
   it in "Flagged ambiguities" with a clear resolution. Don't leave the
   ambiguity in someone else's head.

6. **Respect existing entries.** Never silently re-define a term. If the
   meaning has shifted, raise it as a question first; if confirmed, update
   the entry and add a `Flagged ambiguities` note recording the change.

## Drafting During a Plan

While inside a plan (see `plan-driven-dev`), do **not** write directly to
`docs/CONTEXT.md`. Instead:

1. Create `<plan-dir>/drafts/context/` if it does not exist.
2. Write each new or amended term to `<plan-dir>/drafts/context/<term-slug>.md`
   as a single-term file using the same format as a `CONTEXT.md` entry:

   ```md
   **TermName**:
   One-sentence definition.
   _Avoid_: alias-1, alias-2
   ```

   Optionally include a short `## Relationships` block at the bottom if the
   term introduces a new relationship.

3. Mark the step in `plan-implementation.md` that ratifies the term with a
   `_Promotes_:` note pointing at the draft file. See `plan-driven-dev`.

The `/step` command promotes the draft into `docs/CONTEXT.md` when that
step completes, and only then. This keeps unratified vocabulary out of the
canonical glossary, and keeps ratified vocabulary aligned with the code
that introduces it.

## Standalone Edits

Outside a plan, use the `/context` command to add or amend a single term
directly in `docs/CONTEXT.md`. This is appropriate for retroactive cleanup,
not for terms that arise from in-flight work — those should go through the
draft+promote flow.

## Bootstrapping

For a repo with no existing `docs/CONTEXT.md`, run `/bootstrap-context`. It
scans the codebase and existing docs for term candidates, presents them
one at a time with supporting evidence, and writes the accepted ones
directly to `docs/CONTEXT.md`.
