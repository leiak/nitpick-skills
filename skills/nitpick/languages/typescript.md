# TypeScript

> **Book sources**: *Effective TypeScript* (Dan Vanderkam); *Programming TypeScript* (Boris Cherny).

If the project is TypeScript, read this file in addition to the six dimension files. Apply these language-specific questions.

## Type Safety

### TS1: Is the type system engaged or defeated?

- Count `any` / `as` / `as unknown as` / `@ts-ignore` / `@ts-expect-error` occurrences. Each is a P2 (a type escape hatch that defeats TypeScript's purpose).
- Is `strict` mode enabled in `tsconfig.json`? Is `noUncheckedIndexedAccess` enabled?
- Is there `any` in public API signatures? This leaks untyped data to all consumers.

### TS2: Are illegal states unrepresentable?

(Vanderkam: "Use discriminated unions, not optional fields. If a state combination should not exist, make the type system forbid it.")

- Are there interfaces with optional fields that can be in impossible combinations?
  ```typescript
  // BAD: illegal state possible — shippedDate set when status != 'shipped'
  interface Order { status: string; shippedDate?: Date }

  // GOOD: illegal states impossible
  type Order =
    | { type: 'unconfirmed'; items: Item[] }
    | { type: 'shipped'; items: Item[]; shippedDate: Date }
  ```

- Are string literals used for statuses instead of union types?
- Are branded types used for validated values (e.g. `type PositiveNumber = number & { __brand: 'positive' }`)?

### TS3: Is null handled explicitly?

- Are `??` fallback chains used to silently swallow undefined? (Vanderkam: "Fail fast — throw a clear error instead of falling through defaults.")
- Are `?.` and `??` used correctly, or are they masking bugs?

## Module Design

### TS4: Is dependency injection used or are dependencies hardcoded?

- Are there `new SomeService()` calls inside methods (tight coupling)? Extract to constructor injection.
- Are there static method calls that make testing impossible?

### TS5: Is immutability preferred?

- Are objects mutated in place when a copy + spread would be clearer?
- Are `const` assertions (`as const`) used for constant objects?
- Are mutable module-level variables shared across imports?

## Async Patterns

### TS6: Are promises handled correctly?

- Unhandled rejections: `asyncFn()` without `await` or `.catch()`.
- Floating promises in constructors or event handlers.
- Sequential `await` that could be `Promise.all()`.

### TS7: Is async error handling comprehensive?

- Are all async operations wrapped in try/catch (or `.catch()`)?
- Are there `async` functions called from sync contexts without error propagation?

## Testing

### TS8: Are tests using real implementations over mocks?

- Preference order: real > fake > stub > mock.
- Over-mocking creates tests that pass while production breaks.

## Performance

### TS9: Are there common TS/JS performance traps?

- Accidental O(n²) in loops with `.find()` / `.filter()` inside.
- Unbounded caches (Map / object growing without eviction).
- Large dependencies imported for small features (`moment` for one date, `lodash` full import for one function).
- Bundle size: is there code splitting? Are there barrel files that force importing everything?

## Cross-Dimension Hooks

- Heavy use of `any` / `as` → tag `@root:no-types`
- Missing discriminated unions → note this in Architecture (state management)
- Over-mocking in tests → note this in Testing (coupling)

## Advanced TypeScript (from *Programming TypeScript* and *Effective TypeScript*)

### TS10: Is the type system used for domain modeling?

(Cherny: "Types are the language of API design in TypeScript. The more precise the type, the more runtime errors are caught ahead of time.")

- Are generic constraints used (`<T extends BaseEntity>`) to express relationships?
- Are mapped types (`{ [K in keyof T]: ... }`) used to derive types from existing ones?
- Are conditional types (`T extends U ? X : Y`) used for type-level logic?
- Are template literal types used for string manipulation at the type level?
- Are `satisfies` operators used (TypeScript 4.9+) to validate without widening?

### TS11: Are API types designed for developer experience?

(Vanderkam: "If it type-checks, it should work. Error messages should be short and easy to understand. Auto-complete should nudge users toward working code.")

- Do type errors produce readable messages, or are they walls of text?
- Are discriminated unions used with a `type` field for easy narrowing?
- Are overloads used to provide better auto-complete for different call patterns?
- Are `unknown` and `never` used at boundaries (instead of `any`)?

### TS12: Are TypeScript decorators used correctly?

- Are decorators applied with the correct order and metadata?
- Are experimental decorators (`experimentalDecorators` in tsconfig) vs standard decorators noted?
- Are decorators typed correctly with `TypedPropertyDescriptor<T>`?
