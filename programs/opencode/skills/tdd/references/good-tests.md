# Good Tests vs Bad Tests

The single distinction that matters: **does the test verify behaviour
through the public interface, or does it verify implementation
details?**

## Good Tests

Good tests:

- Exercise real code paths through public APIs
- Describe **what** the system does, not **how**
- Survive refactors of internal structure
- Use vocabulary from `docs/CONTEXT.md` in their names
- Mock only what genuinely cannot be run (external APIs, clock, slow
  I/O)
- Read like specifications a non-implementer could understand

### Examples

```go
func TestDelivery_RetriesOnce_On_503(t *testing.T) { ... }
func TestDelivery_GivesUp_AfterMaxAttempts(t *testing.T) { ... }
func TestDelivery_DoesNotRetry_On_404(t *testing.T) { ... }
```

The test name reads as a behaviour. The implementation could be
restructured entirely — split into multiple modules, given different
internal types, rewritten in a different style — and the test would
still pass if the behaviour was preserved.

## Bad Tests

Bad tests:

- Mock internal collaborators
- Test private methods directly
- Verify state through means other than the public interface (e.g.
  reading rows from the database when there's a query API)
- Break when you rename internal functions or restructure modules
- Pass when behaviour breaks; fail when behaviour is fine
- Encode the implementation in the assertions

### Examples

```go
// Asserts on internal struct shape, not behaviour.
func TestRetryConfig_HasMaxAttemptsField(t *testing.T) {
    var cfg RetryConfig
    _ = cfg.MaxAttempts // compiles? pass.
}

// Mocks every collaborator. Test passes even if delivery is broken.
func TestSendDelivery_CallsBackoff(t *testing.T) {
    mockBackoff := new(MockBackoff)
    mockBackoff.On("Wait", mock.Anything).Return(nil)
    s := NewSender(mockBackoff)
    s.Send(req)
    mockBackoff.AssertCalled(t, "Wait", time.Second)
}

// Verifies via the database, not the API.
func TestSendDelivery_WritesAuditRow(t *testing.T) {
    s.Send(req)
    var count int
    db.QueryRow("SELECT count(*) FROM audit").Scan(&count)
    assert.Equal(t, 1, count)
}
```

In each case, the test is coupled to the implementation. Renaming
`Wait` to `Sleep` breaks the second test even though no behaviour
changed. Replacing the audit table with a stream breaks the third even
though the audit behaviour is preserved (the public API still reports
audited deliveries).

## The Refactor Test

Whenever you have a test in front of you, ask: **"If I refactor the
implementation without changing behaviour, will this test still pass?"**

- If yes, the test is testing behaviour. Keep it.
- If no, the test is testing implementation. Either rewrite it to
  assert through the public interface, or delete it.

This is the single most useful question to ask about test quality. Run
it on tests you write, and on tests you inherit.

## On Mocking

Mock when:

- The collaborator makes real network calls to systems outside your
  control (third-party APIs, payment providers, identity providers).
- The collaborator depends on real time (clocks, schedulers).
- The collaborator has unbounded latency or cost (LLMs, slow batch
  systems).

Don't mock:

- Your own internal modules. Mocking them couples your test to your
  module structure.
- The database — use a real one (sqlite for unit speed, the real
  engine for integration). Mocking SQL produces tests that pass while
  the real query is broken.
- File I/O — use a temp directory.
- Pure logic — there's nothing to mock.

When in doubt, prefer integration-style tests with the smallest
possible amount of mocking. The cost of slightly slower tests is much
lower than the cost of tests that lie.

## Test Names

Use the project's domain vocabulary from `docs/CONTEXT.md`. Test names
are documentation; they should read like sentences a domain expert
would recognise.

Patterns that work:

- `TestSubject_Behaviour_UnderCondition`
- `Test_<scenario>` (top-level scenario tests)
- BDD-style `Describe / Context / It` if your test framework supports
  it

Patterns to avoid:

- Test names that name the function under test
  (`TestProcessOrder_Success`) — they encode implementation, not
  intent.
- Generic names (`TestHappyPath`, `TestEdgeCase1`) — they say nothing
  about what's being verified.

## When A Test Is Hard To Write

If a test is hard to write, the test isn't the problem — the code is.

- Hard to set up? The module has too many dependencies. Deepen it.
- Hard to assert on? The public interface doesn't expose the
  behaviour. Either add an observation point or rethink whether this
  is really one behaviour.
- Hard to isolate? The module is doing too much. Split it.

Test pain is design feedback. Use it.
