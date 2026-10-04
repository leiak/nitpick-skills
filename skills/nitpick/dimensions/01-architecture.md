# Architecture & Design

Score how well the project's structure supports change, testability, and long-term velocity.

Before scoring, re-read `00-rubric.md` for severity definitions and score anchors.

> **Book sources**: *A Philosophy of Software Design* (Ousterhout); *The Pragmatic Programmer* (Hunt & Thomas); *Clean Code* Ch.8-11 (Martin).

## Diagnostic Questions

### D1: Are the modules deep or shallow?

(Ousterhout: "The most important design principle — make modules deep.")

A deep module has a simple interface hiding a rich implementation. A shallow module has an interface as complex as its implementation.

For each major module:
- Count public methods/exports. Compare to internal complexity.
- **Shallow red flag**: interface exposes as many concepts as it implements.
- **Shallow red flag**: pass-through methods — a method that does nothing except delegate to another method. Each pass-through transfers the caller's complexity to the interface without adding functionality.
- Deep example: Unix file I/O — 5 calls (`open`, `read`, `write`, `lseek`, `close`) hide buffering, caching, drivers, permissions.
- Shallow example: Java file reading — `BufferedReader` wraps `FileReader` wraps `FileInputStream`; interface complexity matches implementation complexity.

**P1 if**: pass-through methods exist. **P2 if**: interface complexity ≈ implementation complexity.

### D2: Is complexity being pulled downward?

(Ousterhout: "When complexity is unavoidable, put it in the implementation, not the interface. It is more important for a module to have a simple interface than a simple implementation.")

- If a module needs to handle an edge case, is the complexity handled internally (pulling complexity down) or exposed to every caller (pushing complexity up)?
- Configuration: does the module require callers to pass many parameters, or does it provide sensible defaults?
- Are there "special case" conditionals in the hot path of callers that the module could absorb internally?

### D3: Are errors defined out of existence?

(Ousterhout: "The best way to handle exceptions is to define APIs so they do not have exceptions. Exceptions are contagious — every caller must know about them.")

Ousterhout's strategies, in order of preference:

| Strategy | Description | Example |
|----------|-------------|---------|
| **Define away** | Change semantics so the "error" is not an error | Java `substring` could clamp out-of-range indices instead of throwing; Unix deletes an open file only when the last reference is released |
| **Mask** | Handle and recover in the lower layer so callers never see it | Retry a transient DB failure inside the data layer |
| **Aggregate** | Single handler for multiple error types | A middleware catches all auth errors uniformly |
| **Just crash** | Unrecoverable errors — do not pretend you can handle them | Missing/corrupt config at startup: crash with a clear message rather than threading an error through 10 layers |

For each error type in the codebase:
- Could the semantics be redefined so this error cannot occur?
- Is the caller being forced to handle a case it cannot fix (Ousterhout: "If the config is missing at startup, no amount of error handling will fix it")?
- Is the error being swallowed silently when it should be defined away or crashed on?

**P2 if**: an error propagates through layers that cannot do anything useful with it.

### D4: Was it designed twice?

(Ousterhout: "Before you commit to a design, produce a second one that is genuinely different — a different decomposition, with the boundaries in different places.")

- Is there evidence that at least two designs were considered (ADR, design doc, code comment)?
- If not, was the first acceptable design mistaken for the best available design?
- For critical modules, check if there is an alternative noted in documentation.

**P3 if**: no evidence of alternative designs (this is common but worth noting).

### D5: Is information hidden or leaked?

(Ousterhout: "Each module should own specific design decisions that no other module knows about.")
(Martin Ch.8: "Do not widely pass around over-flexible or change-prone objects of third-party libraries. Write learning tests to understand and control third-party boundaries.")

- Does the same knowledge (business rule, format, algorithm) exist in multiple modules? This is information leakage.
- Are third-party library types (e.g. `express.Request`, `moment.Moment`) passed through your public APIs? If the library changes, every consumer breaks.
- Are there "learning tests" (tests that document the expected behavior of a third-party library) to catch breaking changes?
- Is there an adapter layer between third-party libraries and your domain code?

**P1 if**: third-party types are exposed in domain-layer function signatures.

### D6: Are components orthogonal?

(Hunt & Thomas: "Two or more things are orthogonal if changes in one do not affect the others.")

- Write "shy" code: code that does not reach out to everything, does one thing well, and ignores the rest.
- Can you test a component in isolation without mocking half the system?
- Does changing the UI require touching the data layer? If yes, they are not orthogonal.
- Count: how many files change when you add a new field to the data model? More than 5 suggests poor orthogonality.

### D7: Does each class have a single reason to change?

(Martin Ch.10: "A class should have only one responsibility — only one reason to change. If a 25-word description of the class responsibilities uses the term 'and', be wary.")

- Pick the 3 largest classes. Write a 25-word description of what each does.
- Does the description contain "and"? If yes, consider splitting.
- Cohesion check: if a subset of the class's member variables is used by only a subset of its methods, that subset may be a second responsibility that should become its own class.

### D8: Are different layers using different abstractions?

(Ousterhout: "Different layers should have different abstractions. Cap layers: lower layers = low-level details; upper layers = business logic.")

- Do upper layers use the same concepts as lower layers, or are they translated?
- If a "service" layer just forwards the same object types from controller to repository, it is adding no abstraction value.

### D9: Is every piece of knowledge represented once?

(Hunt & Thomas: "DRY — Every piece of knowledge must have a single, unambiguous, authoritative representation within a system.")

DRY is not about copying code — it is about duplicating knowledge. Two similar-looking functions that serve different purposes are not a DRY violation.

- Is the same business rule implemented in multiple places?
- Is the same validation logic duplicated in client and server code?
- Are there configuration values scattered across files?

### D10: How is state and concurrency managed?

(Martin Ch.13: "Concurrency is a decoupling strategy — it decouples what is done from when it is done. It is very hard. Keep concurrency management separate from other code. Severely limit access to data. Prefer copies over sharing. Keep locked sections as small as possible.")

- Is there global mutable state?
- Are concurrency concerns (locks, thread pools, async coordination) separated into their own modules, or mixed with business logic?
- Are shared mutable objects passed between threads/components? Prefer immutable data or copies.
- Are there locked/synchronized sections larger than needed?

## Red Flags Summary (adapted from Ousterhout)

| Red Flag | Symptom |
|----------|---------|
| Shallow module | Interface complexity ≈ implementation complexity |
| Information leakage | Same knowledge in multiple modules |
| Temporal decomposition | Code split by execution time, not by information |
| Overexposure | Too many methods/params in an interface |
| Pass-through methods | Method does little except call another |
| Special-general mixture | General-purpose code mixed with special-purpose |
| Conjoined methods | Cannot understand one without reading the other |
| Comment repeats code | Comment says what code obviously does |
| Vague name | Name does not convey enough information |
| Hard-coded dependency | Third-party types in domain layer signatures |

## Cross-Dimension Hooks

- If business logic is entangled with framework code → tag `@root:fat-controllers`
- If global mutable state makes testing impossible → tag `@root:no-tests`
- If information leakage causes duplication → tag `@root:no-tests` (inconsistent behavior across copies is untestable)
- If errors propagate through layers that cannot handle them → note this in Code Quality (error handling)
