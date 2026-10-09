# Swift

> **Book sources**: *The Swift Programming Language* (Apple); WWDC Protocol-Oriented Programming talks; *Advanced Swift* (Ole Begemann et al.).

If the project is Swift, read this file in addition to the six dimension files. Apply these language-specific questions.

## Protocol-Oriented Design

### SW1: Are protocols preferred over inheritance?

(Apple WWDC: "Protocol-oriented programming divorces the definition of behavior from its implementation. Instead of forcing objects to inherit from a parent class, a protocol acts as a lightweight contract.")

- Are protocols used to define behavior instead of base classes?
- Are protocol extensions used to provide default implementations (reducing boilerplate)?
- Is composition (structs + protocols) preferred over class inheritance?
- Are generics used with protocol constraints (`func process<T: SomeProtocol>(_ item: T)`)?

### SW2: Are value types preferred?

(Apple WWDC: "Structs are very lightweight and have value semantics. With value types you have much better encapsulation.")

- Are `struct` used for data models instead of `class`?
- Are `enum` with associated values used for state machines instead of class hierarchies?
- Is `let` used for immutable values?
- Are there `class` types that could be `struct` (only use classes for reference semantics — identity, shared mutable state, Objective-C interop)?

## Optional Safety

### SW3: Is optional handling correct?

- Are force unwraps (`!`) used? Each is P1 (crashes if nil).
- Are implicitly unwrapped optionals (`var x: String!`) used outside of Interface Builder contexts?
- Are `guard let` / `if let` used for safe unwrapping?
- Is nil-coalescing (`??`) used with meaningful defaults?
- Are optional chaining (`?.`) and `map` / `flatMap` on optionals used idiomatically?

## Memory Management

### SW4: Are retain cycles prevented?

- Are `weak` / `unowned` references used in closures that capture `self`?
- Are delegate properties declared as `weak`?
- Are there `deinit` methods for cleanup where needed?
- Are timers / notification observers properly invalidated / removed?

## Error Handling

### SW5: Is error handling done with `throws`?

- Are custom error enums used (conforming to `Error`) instead of generic `NSError`?
- Are `try?` and `try!` used correctly? (`try!` crashes on error; use only when failure is impossible.)
- Are `do-catch` blocks specific (catching the narrowest error type)?
- Are errors propagated with `throws` instead of being swallowed?

## Concurrency

### SW6: Is Swift Concurrency used correctly?

- Are `async` / `await` used instead of completion handlers?
- Are `actor` types used for shared mutable state?
- Is `@MainActor` used for UI-related code?
- Are `Task` lifetimes managed (structured concurrency)?
- Are `async let` used for parallel sub-tasks instead of sequential awaits?

## Cross-Dimension Hooks

- Force unwraps → note this in Security (crash on nil)
- Strong reference cycles → note this in Performance (memory leaks)
- Missing actor isolation → note this in Architecture (data races)
