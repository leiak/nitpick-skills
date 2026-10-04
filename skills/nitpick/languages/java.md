# Java

> **Book sources**: *Effective Java* (Joshua Bloch, 3rd ed.); *Clean Code* (Martin).

If the project is Java, read this file in addition to the six dimension files. Apply these language-specific questions.

## Object Creation

### JV1: Are object creation patterns used correctly?

(Bloch Item 1: "Consider static factory methods instead of constructors.")
(Bloch Item 2: "Consider a builder when faced with many constructor parameters.")

- Are there constructors with more than 4 parameters? If yes, a builder should be used.
- Are static factory methods used for object creation where they add clarity (`List.of()`, `Optional.of()`)?
- Are singletons implemented with enum or private constructor (Bloch Item 3)?
- Are utility classes made non-instantiable with private constructors (Bloch Item 4)?

### JV2: Is dependency injection used?

(Bloch Item 5: "Prefer dependency injection to hardwiring resources.")

- Are resources created inside methods (`new DatabaseConnection()`), or injected via constructor?
- Is a DI framework (Spring, Guice) used consistently, or are there manual workarounds?

### JV3: Is mutability minimized?

(Bloch Item 15: "Minimize mutability. If an object is immutable, it can be in only one state, and you win big.")

- Are classes designed for immutability where possible (final fields, no setters, defensive copies)?
- Are there unnecessary setters that break invariants?
- Are mutable objects shared between threads without synchronization?

## Access Control

### JV4: Is information hidden?

(Bloch Item 13: "Minimize the accessibility of classes and members. If you hide information, you are free to change it without risking harm to the system.")

- Are there `public` fields that should be `private` with getters?
- Are there `public` methods that should be package-private or protected?
- Are interfaces used to expose API, or are concrete classes leaked?

## Generics & Type Safety

### JV5: Are generics used properly?

(Bloch Item 23: "Do not use raw types. If a library designer took the time to write a generic library, take advantage of it.")

- Are there raw types (`List` instead of `List<String>`)?
- Are bounded wildcards used correctly (`<? extends T>` for producers, `<? super T>` for consumers — PECS)?
- Are there unnecessary casts that generics could eliminate?
- Are enums used instead of `int` constants (Bloch Item 30)?

## Resource Management

### JV6: Are resources managed correctly?

(Bloch Item 9: "Prefer try-with-resources to try-finally.")

- Is try-with-resources used for `AutoCloseable` resources?
- Are there resource leaks (streams, connections not closed)?
- Are finalizers/cleaners avoided (Bloch Item 8: they are unpredictable)?

## Annotations

### JV7: Are annotations used for safety?

(Bloch Item 36: "Consistently use @Override. It saves you from errors that would otherwise be hard to detect.")

- Is `@Override` used on all overridden methods?
- Is `@SuppressWarnings` used narrowly (with a comment explaining why)?
- Are there common override bugs (accidental overloading of `equals` instead of overriding)?

## Performance

### JV8: Are there Java-specific performance traps?

(Bloch Item 6: "Avoid creating unnecessary objects.")

- `String s = new String("bikini")` instead of `String s = "bikini"`.
- `Long sum = 0L` in a loop (autoboxing overhead) instead of `long sum = 0L`.
- `Pattern.compile()` inside a method instead of a static final field.
- N+1 in JPA/Hibernate queries.
- Unbounded caches without eviction.

## Cross-Dimension Hooks

- Public mutable fields → tag `@root:fat-controllers` (no encapsulation)
- Missing DI → note this in Testing (hard to mock)
- Raw types → tag `@root:no-types`
