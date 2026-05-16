# Vertical Slices

How to split work into behaviour-shaped steps during plan breakdown.

## The Test

For each candidate step, ask: **"What user-observable behaviour does
this step add through the public interface?"**

If the answer is a behaviour, the step is vertical.

If the answer is a layer, a component, a struct, or "scaffolding for
later", the step is horizontal — push back on it.

## Vertical Step Examples

These are good:

- *"A delivery is retried once on a 503 response"*
- *"A delivery gives up after 5 failed attempts"*
- *"A 4xx response is not retried"*
- *"Backoff doubles between attempts up to a 30-second cap"*
- *"A delivery that exhausts retries is moved to the dead-letter table"*

Each one names a behaviour. Each one can be exercised end-to-end. Each
one has a clear "done when" criterion phrased as observed behaviour.

## Horizontal Step Examples

These are bad:

- *"Set up the retry config struct"* — shape, not behaviour
- *"Add database migration for dead-letter table"* — infrastructure
  setup decoupled from any behaviour
- *"Refactor the webhook module to extract a RetryPolicy interface"* —
  refactor decoupled from any test
- *"Write all the tests for the retry path"* — horizontal split inside
  a single step
- *"Implement exponential backoff calculation"* — algorithm change
  decoupled from any observable consequence

When you spot one of these, ask: "What behaviour will this enable, and
can we deliver that behaviour as a single step that includes whatever
scaffolding it needs?" Usually the answer is yes.

## When Scaffolding Is Genuinely Needed

Some setup work has no user-visible behaviour but is required by the
tracer bullet. For example: adding a new package, wiring it into the
build, ensuring tests can run against it.

The right move is to **fold the scaffolding into the tracer bullet**:
step 1 sets up the package *and* delivers the first observable
behaviour. The package isn't proven until something runs through it
end-to-end, so there is no value in landing the package alone.

If the scaffolding is large enough that it would dominate the tracer
bullet, that's a sign the tracer bullet is too thin — pick a slightly
larger first behaviour that earns the scaffolding.

## When To Insert A Refactor Step

Refactor work earns its own step when:

- It is large enough that bundling it with a behaviour change would
  hide the behaviour change in noise.
- It does not change behaviour but enables several upcoming behaviour
  steps.
- All the existing tests continue to pass — the refactor is verified by
  unchanged behaviour, not new behaviour.

Mark such steps as `**Refactor** — ...`. Acceptance criterion: "Done
when: existing tests still pass; no new behaviour added."

Do not insert refactor steps for work that *might* be useful later. Wait
until at least two upcoming behaviour steps would benefit. One adapter
is a hypothetical seam; two is a real one.

## Sequencing

Order steps so each one builds on the previous. Specifically:

1. **Tracer bullet first** — the thinnest end-to-end path. Establishes
   the wiring.
2. **Happy-path expansions next** — each step adds one more
   capability on the same path (backoff, jitter, etc.).
3. **Edge cases and error paths** — once the happy path is solid, layer
   on what happens when things go wrong (4xx not retried, max attempts
   exhausted, dead-letter).
4. **Operational concerns last** — observability, metrics, retry
   inspection endpoints. These are real behaviour and deserve real
   steps; they just don't usually block the core feature.

This order minimises rework. If you discover halfway through that the
tracer bullet's wiring was wrong, you've wasted one step instead of ten.

## Sizing

A step is the right size when:

- It can be implemented and verified in a single sitting (typically
  one to a few hours of focused work).
- Its acceptance criterion is a single sentence describing one
  observable behaviour.
- The test for it can be written before the implementation, and that
  test will fail until the implementation lands.

Too big: the step contains "and" or "also". Split it.

Too small: the step doesn't deliver any new observable behaviour. Merge
it with the next step that does.
