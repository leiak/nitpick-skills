# Go

> **Book sources**: *Effective Go* (Go team); *The Go Programming Language* (Donovan & Kernighan); Go Proverbs (Rob Pike).

If the project is Go, read this file in addition to the six dimension files. Apply these language-specific questions.

## Go Idioms

### GO1: Is the code idiomatic Go?

(Rob Pike: "Clear is better than clever. Don't communicate by sharing memory; share memory by communicating.")

- Does `gofmt` pass? Is `go vet` clean?
- Are Go naming conventions followed (mixedCaps, no underscores, short names for short scopes)?
- Is `main` kept thin (configuration, wiring, lifecycle only)? Business logic should be in importable packages.

### GO2: Are interfaces small and composable?

(Go Proverbs: "The bigger the interface, the weaker the abstraction.")

- Are interfaces defined at the consumer side (where they are used), not the producer side?
- Are interfaces small (1-3 methods)?
- Are there "god" interfaces that many types implement but few consumers need?
- Is composition over inheritance used (embedding, not extends)?

### GO3: Are errors handled idiomatically?

(Go: "Errors are values. Error handling code is just code.")

- Are all `error` return values checked? (`rg "if err" -c` — compare to function count.)
- Are errors wrapped with context (`fmt.Errorf("doing X: %w", err)`)?
- Are `errors.Is` / `errors.As` used instead of string comparison?
- Are `panic`/`recover` used only for truly unrecoverable situations (not for control flow)?
- Are sentinel errors defined for expected conditions (`var ErrNotFound = errors.New("not found")`)?

### GO4: Is context propagated?

- Is `context.Context` accepted as the first argument in I/O, RPC, and potentially blocking functions?
- Are context deadlines/timeouts set?
- Is context propagated through all layers (not created fresh in each function)?
- Is `context.Background()` only used at the top level (main, request handler entry)?

## Concurrency

### GO5: Are goroutines managed properly?

- Does every goroutine have a termination path (context cancellation, done channel, WaitGroup)?
- Are channels used for communication between goroutines (not shared memory + mutexes unless necessary)?
- Are `sync.WaitGroup` / `errgroup.Group` used for coordinating multiple goroutines?
- Are buffered channels sized appropriately (or unbounded, risking OOM)?

### GO6: Is the race detector run?

- Is `go test -race ./...` part of the test suite?
- Are there known data races (shared state accessed without synchronization)?

### GO7: Are resources properly closed?

- Are `defer file.Close()`, `defer resp.Body.Close()`, `defer conn.Close()` called immediately after successful acquisition?
- Are there goroutine leaks (goroutines blocked on channels that no one reads)?

## Testing

### GO8: Are tests table-driven and deterministic?

- Are table-driven tests used for functions with multiple input/output combinations?
- Is `t.Helper()` used in test helpers?
- Is `t.Cleanup()` used instead of `defer` for cleanup in helpers?
- Are tests parallel where appropriate (`t.Parallel()`)?
- Do tests avoid depending on external state?

## Performance

### GO9: Are there Go-specific performance traps?

- Unnecessary allocations in hot paths (check for `[]byte(string)` conversions in loops).
- Missing `sync.Pool` for frequently allocated objects.
- `GOMAXPROCS` not set in containerized environments.
- Slice append without pre-allocation for known-size data.

## Cross-Dimension Hooks

- Unchecked errors → tag `@root:no-tests` (errors are silently dropped)
- Missing context propagation → note this in Performance (no timeout control)
- Race conditions → tag `@root:no-tests` (race detector not run)
