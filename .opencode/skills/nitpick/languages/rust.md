# Rust

> **Book sources**: *The Rust Programming Language* (Klabnik & Nichols); *Programming Rust* (Blandy & Orendorff); *Rust for Rustaceans* (Jon Gjengset).

If the project is Rust, read this file in addition to the six dimension files. Apply these language-specific questions.

## Ownership & Borrowing

### RU1: Is ownership used idiomatically?

- Are `clone()` calls justified? Each `clone()` is a potential performance issue. Is it truly needed, or can a reference/borrow be used?
- Are `unsafe` blocks present? Each must be justified with a comment explaining why it is safe.
- Are there unnecessary `Rc<RefCell<T>>` / `Arc<Mutex<T>>` where single ownership suffices?
- Are lifetimes explicit where the compiler cannot infer them? Are lifetime names meaningful?

### RU2: Is error handling done with `Result`?

- Are `unwrap()` / `expect()` used outside tests? Each is P1 (panics on error).
- Are custom error types used with `thiserror` or manual `impl std::error::Error`?
- Is `?` used for error propagation?
- Are errors converted between types properly (using `From` / `Into`)?

## API Design

### RU3: Are traits used for abstraction?

- Are trait bounds used instead of concrete types in function parameters where appropriate?
- Are there "god traits" with many methods?
- Are `impl Trait` used for return types when concrete type is not important?
- Are generics used with the right trait bounds (`Send`, `Sync`, `'static`)?

### RU4: Is the type system leveraged?

- Are newtypes used to distinguish domain concepts (`struct UserId(u64)` instead of raw `u64`)?
- Are enums with data used for state machines instead of structs with status fields?
- Are exhaustive `match` expressions used (no `_ =>` catch-all when all variants should be handled)?

## Concurrency

### RU5: Is concurrency safe and appropriate?

- Are `Send` and `Sync` bounds properly constrained?
- Are there deadlocks (nested lock acquisitions)?
- Is `tokio` or another async runtime used consistently?
- Are blocking calls inside `async` functions avoided (they block the executor)?

## Testing

### RU6: Are tests comprehensive?

- Are unit tests in `#[cfg(test)]` modules colocated with source?
- Are integration tests in `tests/` directory?
- Are `should_panic` tests used for error paths?
- Are property-based tests used (`proptest`, `quickcheck`) for complex logic?

## Performance

### RU7: Are there Rust-specific performance concerns?

- Unnecessary allocations (String vs &str, Vec vs slice).
- Missing `#[inline]` on hot-path functions.
- Excessive `Box` / `Rc` indirection in hot paths.
- Unnecessary `.collect()` followed by iteration.

## Cross-Dimension Hooks

- `unwrap()` in production code → note this in Security (crash on malformed input)
- `unsafe` blocks without justification → tag `@root:no-tests` (untestable memory safety)
- Missing newtype wrappers → note this in Code Quality (naming and type safety)

## Advanced Rust (from *Rust for Rustaceans* and *Zero to Production in Rust*)

### RU8: Is async Rust used correctly?

(Palmieri, *Zero to Production*: "Async Rust has subtle pitfalls — blocking the executor, holding non-Send data across await points, and unstructured task spawning.")

- Are blocking calls (synchronous I/O, CPU-heavy loops) inside `async` functions avoided? Use `tokio::task::spawn_blocking` instead.
- Are `Send` bounds satisfied when holding data across `.await` points?
- Is `tokio::select!` used for timeout and cancellation patterns?
- Are tasks spawned with structured concurrency (`tokio::spawn` within a scope that joins them)?

### RU9: Is error handling production-grade?

(Gjengset, *Rust for Rustaceans*: "Error handling in Rust goes beyond Result — it is about designing error types that are ergonomic, composable, and preserve information.")

- Are error types `Send + Sync + 'static` (required for cross-thread propagation)?
- Is `thiserror` used for library errors and `anyhow` for application errors?
- Are error sources chained correctly (`.source()` traversal works)?
- Are opaque errors used at API boundaries (hide internal types)?

### RU10: Are lifetime patterns understood?

- Are there `'static` bounds used correctly?
- Are self-referential structs avoided (or handled with `pin-project`)?
- Are `Cow<'a, T>` used to avoid unnecessary clones?
- Are trait objects (`dyn Trait`) used with explicit lifetime annotations where needed?
