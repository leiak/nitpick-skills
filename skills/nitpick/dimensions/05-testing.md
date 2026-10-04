# Testing & Reliability

Score how well the project catches bugs before production and degrades gracefully when things fail.

Before scoring, re-read `00-rubric.md` for severity definitions and score anchors.

> **Book sources**: *Growing Object-Oriented Software Guided by Tests* (Freeman & Pryce); Martin Fowler's Test Pyramid; Clean Code Ch.9 (Martin) for clean tests.

If the project has zero test files, the score is 0-1. Do not sugarcoat this.

## Diagnostic Questions

### T1: Does the test distribution follow the pyramid?

(Cohn's Test Pyramid, endorsed by Fowler: "More unit tests than broad-stack tests. The pyramid assumes that broad-stack tests are expensive, slow, and brittle compared to focused unit tests.")

Map existing tests to layers:

| Layer | What it tests | Ideal proportion | Speed | Fragility |
|-------|--------------|-----------------|-------|-----------|
| Unit | Individual functions/classes in isolation | ~70% | Fast (ms) | Low |
| Integration | Multiple components working together | ~20% | Medium (s) | Medium |
| End-to-end | Full system through the UI/API | ~10% | Slow (min) | High |

Red flags:
- **Ice cream cone**: more E2E tests than unit tests → slow, brittle, hard to debug, edge cases missed
- **Inverted pyramid**: only E2E tests, no unit tests → bugs found late
- **Hourglass**: many unit tests and E2E tests but no integration tests → component interactions untested

(Fowler: "If you have a failing high-level test, not only do you have a bug in your functional code, you are also missing a unit test. Fix the bug by first reproducing it with a unit test, then ensure the bug never returns.")

If a test suite exists, estimate its shape. If the shape is wrong, flag P2.

### T2: Is testability treated as a design concern?

(Freeman & Pryce: "Automated testing is not just about ensuring the software behaves as expected — it is about designing the software.")

- Can you unit-test business logic without spinning up a server or database?
- If not, the architecture makes testing impossible → tag `@root:fat-controllers`.
- Does the code have clear seams (dependency injection, interfaces) that make testing possible?
- Are tests written before implementation (TDD) or as an afterthought?

### T3: Do the tests follow clean test principles?

(Martin Ch.9: "Test code is just as important as production code. It is not a second-class citizen. It requires thought, design, and care.")

**Test state, not interactions**: Assert on the *outcome* of an operation, not on which methods were called internally. Tests that verify method call sequences break when you refactor, even if behavior is unchanged.

**DAMP over DRY in tests**: In production code, DRY is usually right. In tests, **DAMP** (Descriptive And Meaningful Phrases) is better. Each test should read like a specification — a complete story without requiring the reader to trace through shared helpers.

**Mock preference order** (most to least preferred):
1. **Real implementation** → Highest confidence, catches real bugs
2. **Fake** → In-memory version of a dependency (e.g., fake DB)
3. **Stub** → Returns canned data, no behavior
4. **Mock** (interaction) → Verifies method calls — use sparingly

Use mocks only when: the real implementation is too slow, non-deterministic, or has uncontrollable side effects (external APIs, email sending). Over-mocking creates tests that pass while production breaks.

**One assertion per concept**: Each test should test one behavior. Multiple assertions are fine if they all verify one logical outcome.

**Arrange-Act-Assert**: Structure tests in three sections. If you cannot, the test is doing too much.

### T4: Are edge cases covered?

For each critical function:
- Empty input (empty string, empty array, empty object)
- Null / undefined / None values
- Boundary values (0, 1, -1, max int, min int)
- Unicode and special characters
- Concurrent access (race conditions, duplicate submissions)
- Error paths (what happens when the dependency fails?)

### T5: What are the test anti-patterns?

| Anti-pattern | Problem | Fix |
|--------------|---------|-----|
| Testing implementation details | Tests break when refactoring even if behavior is unchanged | Test inputs and outputs, not internal structure |
| Flaky tests (timing, order-dependent) | Erode trust in the suite | Use deterministic assertions, isolate test state |
| Testing framework code | Wastes time testing third-party behavior | Only test YOUR code |
| Snapshot abuse | Large snapshots nobody reviews | Use sparingly, review every change |
| No test isolation | Tests pass individually but fail together | Each test sets up and tears down its own state |
| Mocking everything | Tests pass but production breaks | Prefer real implementations > fakes > stubs > mocks |

### T6: Does the system degrade gracefully?

- Are there timeouts on external calls?
- Are there retry mechanisms with backoff for transient failures?
- What happens when a dependency is unavailable? Crash or graceful error?
- Are there health check endpoints (for services)?

### T7: Can you debug a production issue?

- Is there structured logging (JSON with levels, timestamps, request IDs)?
- Are errors logged with enough context to diagnose without reproducing locally?
- Are there metrics/monitoring hooks (needed for USE/RED methods)?
- Are log levels used meaningfully (debug/info/warn/error)?

## Cross-Dimension Hooks

- If no tests exist because the architecture makes testing impossible → tag `@root:fat-controllers`
- If no CI means tests are never run → tag `@root:no-ci`
- If no type system makes it hard to write type-safe assertions → tag `@root:no-types`
- If tests are over-mocked → note this in Architecture (coupling — hard to test without mocking means tight coupling)
