# C Sharp / .NET

> **Book sources**: *C# in Depth* (Jon Skeet); *CLR via C#* (Jeffrey Richter); Microsoft .NET guidelines.

If the project is C#, read this file in addition to the six dimension files. Apply these language-specific questions.

## Null Safety

### CS1: Are nullable reference types enabled?

- Is `<Nullable>enable</Nullable>` set in `.csproj`?
- Are there `#nullable disable` directives that turn off null checking?
- Are null-conditional operators (`?.`) and null-coalescing (`??`) used correctly?
- Are there `!` (null-forgiving) operators? Each hides a potential `NullReferenceException`.

## LINQ

### CS2: Is LINQ used correctly?

- Is deferred execution understood? Queries are not evaluated when defined — only when iterated.
- Are there multiple iterations over the same `IEnumerable<T>` query? (Each iteration re-executes the query. Materialize with `.ToList()` for multi-use.)
- Is `IEnumerable<T>` vs `IQueryable<T>` distinction respected? (`IQueryable` translates to SQL; `IEnumerable` runs in-process. Mixing them with `.AsEnumerable()` early forces all data into memory.)
- Is `.Any()` used instead of `.Count() > 0`? (`.Any()` short-circuits; `.Count()` enumerates fully.)

### CS3: Are there LINQ performance traps?

- `.FirstOrDefault()` inside a loop (O(n²)) instead of building a `Dictionary` lookup.
- `.Select()` loading all columns/relations when only a few are needed (over-fetching).
- Missing `.ToList()` materialization for EF Core queries that are iterated multiple times.

## Async

### CS4: Is async/await used correctly?

- Are there `async void` methods? (Only allowed for event handlers. `async Task` should be used elsewhere.)
- Are there `.Result` / `.Wait()` calls (deadlock risk)? Use `await` instead.
- Are sequential `await`s that could be parallel (`Task.WhenAll`)?
- Is `CancellationToken` threaded through async APIs for cancellation and timeouts?
- Is `ValueTask<T>` used where a method frequently returns synchronously (avoids allocation)?
- Are there fire-and-forget `Task.Run` calls without exception handling?

## Patterns

### CS5: Is pattern matching used?

- Are `is` patterns used instead of `as` + null check?
- Are switch expressions used instead of if/else chains?
- Are positional patterns used for deconstruction?

## Records & Immutability

### CS6: Are records and immutability used?

- Are `record` types used for immutable data models instead of classes with setters?
- Are `init` properties used instead of `set` where values should not change after construction?

## Resource Management

### CS7: Are resources properly disposed?

- Are `using` statements / declarations used for `IDisposable` resources?
- Are there potential resource leaks (HttpClient created per-request instead of IHttpClientFactory)?
- Are event handlers unsubscribed (memory leak prevention)?

## Cross-Dimension Hooks

- `async void` in non-event-handler code → tag `@root:no-tests` (untestable, exceptions crash the process)
- Missing `Nullable` enable → tag `@root:no-types`
- LINQ performance traps → note this in Performance

## Advanced C# (from *CLR via C#* and *Adaptive Code*)

### CS8: Is the CLR understood?

(Richter, *CLR via C#*: "The CLR is the foundation — understand garbage collection, JIT compilation, and assembly loading to write performant code.")

- Are value types (`struct`) used for small, short-lived data (avoiding heap allocation)?
- Are `Span<T>` / `Memory<T>` used for efficient slicing without copies?
- Is `ArrayPool<T>` / `MemoryPool<T>` used for large buffer reuse?
- Are strings interned (`string.Intern()`) where appropriate?
- Are there boxing/unboxing issues (value type stored in `object` or interface)?

### CS9: Is dependency injection used flexibly?

(Hall, *Adaptive Code*: "Design for adaptability — loose coupling through DI enables change without pain.")

- Are interfaces used for all service dependencies (not concrete classes)?
- Is the DI container configured in a single composition root?
- Are lifetimes (Transient, Scoped, Singleton) chosen correctly?
- Are there captive dependencies (Singleton depending on Scoped)?

### CS10: Are source generators and AOT compilation considered?

- Are source generators used for boilerplate elimination (System.Text.Json, Mapperly)?
- Is Native AOT / trimming considered for startup-critical paths?
- Are there reflection-heavy patterns that could be replaced with source-generated code?
