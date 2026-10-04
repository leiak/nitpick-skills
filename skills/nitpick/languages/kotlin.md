# Kotlin

> **Book sources**: *Kotlin in Action* (Jemerov & Isakova); Kotlin official documentation.

If the project is Kotlin, read this file in addition to the six dimension files. Apply these language-specific questions.

## Null Safety

### KT1: Is null safety leveraged?

(Kotlin docs: "Null safety is designed to significantly reduce the risk of null references — The Billion-Dollar Mistake.")

- Are `!!` (not-null assertion) operators used? Each is P1 — it reintroduces NPE that Kotlin's type system prevents.
- Are safe call operators (`?.`) and Elvis operators (`?:`) used correctly?
- Are `lateinit` properties used? If so, are they guaranteed to be initialized before access?
- Are platform types (types from Java interop) treated as nullable when the Java source might return null?

## Coroutines

### KT2: Are coroutines used correctly?

- Is `GlobalScope` avoided? (Coroutines launched in `GlobalScope` are not lifecycle-managed and can leak.)
- Are structured concurrency principles followed (`coroutineScope`, `viewModelScope`, `lifecycleScope`)?
- Are cancellation tokens propagated through the coroutine hierarchy?
- Are `suspend` functions used instead of callbacks?
- Are there blocking calls inside coroutines (use `Dispatchers.IO` for I/O, `Dispatchers.Default` for CPU-bound)?
- Are `Flow` / `StateFlow` / `SharedFlow` used for reactive streams instead of callbacks?

## Kotlin Idioms

### KT3: Is the code idiomatic Kotlin?

- Are data classes used for data-holding classes?
- Are sealed classes used for restricted hierarchies (instead of enums with data or interface + implementations)?
- Are extension functions used instead of utility classes?
- Are `let` / `run` / `with` / `apply` / `also` scope functions used appropriately?
- Are smart casts used instead of explicit casts after type checks?
- Are default parameter values and named arguments used instead of constructor overloads?
- Are delegated properties (`by lazy`, `by Delegates.observable`) used where appropriate?

## Interop

### KT4: Is Java interop handled safely?

- Are `@Nullable` / `@NotNull` annotations used on public APIs that Java code calls?
- Are platform types (`String!`) treated as potentially null?
- Are `@JvmStatic`, `@JvmOverloads` used where Java callers need them?

## Cross-Dimension Hooks

- `!!` operators → note this in Security (NPE reintroduced)
- `GlobalScope` usage → note this in Testing (lifecycle leaks)
- Blocking calls in coroutines → note this in Performance (dispatcher starvation)
