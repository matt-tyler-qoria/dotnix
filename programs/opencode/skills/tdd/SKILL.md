---
name: tdd
description: Test-driven development with vertical slices and the tracer-bullet pattern. Each step in a plan is one observable behaviour, exercised through the public interface, with a RED→GREEN→REFACTOR loop. The first step in any plan is the tracer bullet — the thinnest end-to-end slice that proves the wiring works. Loaded by /plan during step breakdown and by /step during execution.
license: MIT
compatibility: opencode
---

# Test-Driven Development

## Philosophy

Tests verify **behaviour** through **public interfaces**. Implementation
changes; tests don't. A test that breaks because you renamed an internal
function was testing the wrong thing.

Good tests read like specifications: "settles a delivery on first
2xx response", "retries with backoff on 5xx", "gives up after max
attempts". Each one tells you a capability the system has. Bad tests
test shape — that this struct has these fields, that this function takes
these arguments.

See `references/good-tests.md` for the full distinction.

## The Tracer Bullet

The first step of every plan-implementation.md is a **tracer bullet**: the
thinnest possible end-to-end slice that proves the path works.

For a webhook retry feature, the tracer bullet is *not* "set up the retry
config struct". It's *"a single retry on 503, no backoff yet, observed
end-to-end through the public webhook send API"*. Hardcoded delays. No
jitter. No giveup. One real path through real code.

Why: the tracer bullet flushes out integration assumptions before you've
built anything that depends on them. If the wiring is wrong — wrong
package boundaries, wrong dependencies, wrong test harness — you find
out on day one, not week three.

After the tracer bullet, every subsequent step adds one more behaviour
on the same path: backoff, jitter, max-attempts, dead-lettering, etc.
The plan grows by adding capabilities, not by stitching components
together at the end.

## Vertical Slices, Not Horizontal

The single most common TDD failure mode is horizontal slicing: write all
the tests, then write all the code. This produces tests of *imagined*
behaviour, not actual behaviour. Tests written in bulk drift toward
testing structure (this struct has these fields) instead of behaviour
(this input produces this outcome).

```
WRONG (horizontal):
  RED:   test1, test2, test3, test4, test5
  GREEN: impl1, impl2, impl3, impl4, impl5

RIGHT (vertical):
  RED→GREEN: test1 → impl1
  RED→GREEN: test2 → impl2
  RED→GREEN: test3 → impl3
```

In the vertical model, each test responds to what you learned from the
previous cycle. Because you just wrote the code, you know exactly what
matters and how to verify it. Tests stay tight to behaviour because
behaviour is what you just observed.

See `references/vertical-slices.md` for how to split work into
behaviour-shaped steps during plan breakdown.

## Step-Level Loop

When `/step` executes a step, the loop is:

1. **RED** — write the one test for this step's behaviour. Run it. It
   must fail for the right reason (assertion failure or "not
   implemented"), not the wrong reason (compile error from a typo).

2. **GREEN** — write the minimal code that makes the test pass.
   "Minimal" means: do not anticipate the next step. Do not add the
   error handling that step 4 requires. Do not extract the helper that
   step 6 will need. Just pass this test.

3. **REFACTOR** — only when GREEN. Look for duplication, deepening
   opportunities, naming improvements. Run tests after each refactor.
   Never refactor while RED.

Rules:

- One test at a time.
- Only enough code to pass the current test.
- Don't anticipate future tests.
- Tests assert on observable outcomes through the public API, not on
  internal state.

## Plan-Level Rules

When `/plan` builds `plan-implementation.md`, the TDD skill enforces:

1. **Step 1 is the tracer bullet.** Title it explicitly: `**Tracer
   bullet** — ...`. Acceptance criteria phrased as the end-to-end
   behaviour observed.

2. **Each step delivers one observable behaviour.** Acceptance criteria
   phrased in terms of behaviour through the public API. "Done when:
   posting a 5xx triggers exactly one retry" is good. "Done when:
   `RetryConfig` struct compiles" is bad — it's testing shape, not
   behaviour.

3. **Steps respect existing ADRs.** Read `docs/adr/` for ADRs touching
   the area before breaking down steps. Do not propose work that
   contradicts a current ADR without flagging it.

4. **Tests use domain vocabulary.** Test names and interface vocabulary
   come from `docs/CONTEXT.md`. If a step introduces a new term, it
   drafts the term (see `domain-language` skill) and notes
   `_Promotes_:` accordingly.

## What Not to Test

You can't test everything, and trying to is its own failure mode. Focus
on:

- Critical paths
- Behaviour at boundaries (max attempts, empty input, error responses)
- Behaviour the user described in the plan as load-bearing

Skip:

- Trivial getters/setters
- Framework code you don't own
- Implementation details that aren't part of the public interface
- Combinations of behaviours that are exhaustively covered by the
  individual behaviour tests

If a behaviour matters but is too expensive to test at unit level, push
it to integration. If it's too hard to test even there, the design is
probably wrong — that's a deepening signal worth surfacing.

## Mocks

Mocks are for what you can't run in tests, not for what you don't feel
like running. External APIs, system clocks, and slow I/O are
appropriate. Internal collaborators are not — mocking them couples your
test to your implementation.

When in doubt: prefer integration-style tests that exercise real code
through the public interface, with only the genuinely external
collaborators mocked.
