# Ruby

> **Book sources**: *Practical Object-Oriented Design in Ruby* (Sandi Metz); *The Well-Grounded Rubyist* (David Black); *Refactoring Ruby* (Jay Fields et al.).

If the project is Ruby, read this file in addition to the six dimension files. Apply these language-specific questions.

## Object-Oriented Design

### RB1: Does each class have a single responsibility?

(Metz Ch.2: "A class should have one reason to change. Group methods into classes based on what they do, not what they have.")

- Pick the 3 largest classes. Write a one-sentence description. If it contains "and", split it.
- Are there "God classes" (UserManager, ApplicationController) that handle too many concerns?
- Does each method hide one piece of the class's responsibility?

### RB2: Are dependencies managed?

(Metz Ch.3: "Recognize dependencies, inject them, isolate them, and choose dependency direction carefully.")

- Are dependencies injected (passed as arguments) instead of hardcoded?
  ```ruby
  # BAD: hardcoded dependency
  class Gear
    def initialize
      @chainring = Chainring.new  # Gear knows about Chainring
    end
  end

  # GOOD: injected dependency
  class Gear
    def initialize(chainring)
      @chainring = chainring
    end
  end
  ```

- Are argument-order dependencies removed (use keyword arguments)?
- Is dependency direction sensible (depend on abstractions, not concretions)?

### RB3: Are interfaces flexible?

(Metz Ch.4: "Ask for what instead of telling how. Seek context independence.")

- Do public methods reveal *what* an object does, not *how* it does it?
- Are methods named after their intent, not their implementation?
- Is duck typing used instead of `is_a?` / `kind_of?` checks?

## Ruby Idioms

### RB4: Is the code Ruby-idiomatic?

- Are blocks used for iteration instead of manual loops?
- Are `Symbol#to_proc` (`&:method`) used where appropriate?
- Are safe navigation operators (`&.`) used for optional chaining?
- Are `Enumerable` methods (`map`, `select`, `reject`, `reduce`, `each_with_object`) used instead of manual accumulation?
- Are `Struct` / `OpenStruct` used for lightweight data containers?
- Are `attr_accessor` / `attr_reader` used instead of manual getter/setter methods?

### RB5: Are metaprogramming constructs used responsibly?

- Are `method_missing` / `define_method` / `send` used? Each adds complexity.
- Is `eval` used? (Almost never justified; P1.)
- Are monkey patches applied? If yes, are they justified and documented?
- Are `const_missing` / `inherited` hooks used (class-level metaprogramming)?

## Testing

### RB6: Are tests written with RSpec/Minitest best practices?

- Are `let` / `subject` used correctly (lazy evaluation, not hiding setup)?
- Are `before` / `after` hooks used for setup/teardown?
- Are factories (FactoryBot) used instead of fixture files?
- Are tests isolated (no order dependence)?
- Are shared examples / contexts used to reduce duplication without obscuring intent?

## Performance

### RB7: Are there Ruby-specific performance traps?

- N+1 queries in ActiveRecord (use `includes` / `preload`).
- Large string concatenation in loops (use `<<` or `StringIO`).
- Unbounded `Hash` / `Array` growth without eviction.
- Missing memoization on expensive method calls (`@result ||= expensive_computation`).
- Repeated `Time.now` calls in loops (bind to local variable).

## Cross-Dimension Hooks

- God classes → tag `@root:fat-controllers`
- Monkey patches without documentation → note this in Architecture (information hiding)
- N+1 queries → note this in Performance
