# Code Quality

Score the readability, consistency, and defensiveness of the code itself.

Before scoring, re-read `00-rubric.md` for severity definitions and score anchors.

> **Book sources**: *Clean Code* Ch.2-7, 10, 13 (Martin); *The Pragmatic Programmer* (Hunt & Thomas).

## Diagnostic Questions

### Q1: Do names reveal intent?

(Martin Ch.2: "If a name requires a comment, then the name does not reveal its intent.")

Pick 5 non-trivial variables/functions/classes. For each:

- Does the name tell you what it does without reading the implementation?
- Is `int d` used instead of `elapsedTimeInDays`?
- Are class names nouns (`Customer`, `Account`) and method names verbs (`postPayment`, `deletePage`)?
- Is one word per concept — not `fetch`, `retrieve`, and `get` for the same operation?
- Are there "Manager", "Processor", "Data" names that convey nothing?
- Is the name searchable? `MAX_CLASSES_PER_STUDENT` is searchable; `7` is not.
- Does the name length match its scope? Short names are fine in tiny scopes; long names in wide scopes.

**P2 if**: any name requires reading the implementation to understand.

### Q2: Do functions do one thing?

(Martin Ch.3: "Functions should hardly ever be 20 lines long. If you can extract another function with a name that is not just a restatement of its implementation, it is doing more than one thing.")

- Are there functions longer than 50 lines?
- Are there boolean flag arguments? (Martin: "A truly terrible practice — split into two functions.")
- Are there output arguments? (Martin: prefer return values over output params.)
- Do functions operate at a single level of abstraction? (Step-down Rule: readers descend through the code one conceptual level at a time.)
- Are there side effects hiding in seemingly pure functions? (A `checkPassword` that also initializes a session creates hidden temporal coupling.)
- Is the ideal argument count met? (Zero is best, one is fine, two is acceptable, three should be avoided.)
- Does the function have "sections" (blank-line-separated blocks)? If yes, it is doing more than one thing.

### Q3: Are comments earning their place?

(Martin Ch.4: "The proper use of comments is to compensate for our failure to express ourselves in code. Inaccurate comments are far worse than no comments at all.")

Good comments (keep these):

- Legal headers and license notices
- Warnings of consequences ("This will take 5 minutes to run")
- Explanation of intent for genuinely obscure algorithms
- Clarification when the code cannot be made clearer

Bad comments (delete these):

- Redundant (repeat what the code says)
- Misleading or stale (code changed, comment did not)
- Mandated (every function must have a JSDoc)
- Commented-out code ("Few practices are as odious as commenting-out code")
- Journal comments (change logs at the top of files)

- Are there comments that explain *what* the code does when better naming could say it?
- Are there commented-out blocks? (Delete — git preserves history.)
- Are there TODO comments older than a month?

### Q4: What happens when things go wrong?

(Martin Ch.7: "Use exceptions, not return codes. Return codes clutter the caller and are easy to forget.")

- `catch {}` or `except: pass` with no logging — count occurrences. Each is P1.
- Generic `Error` thrown everywhere (no custom types) — P2.
- Unhandled promise rejections — P1.
- Does each error message say what went wrong and where?
- Are errors thrown at the right level, or propagated through layers that cannot handle them?

(Martin Ch.7: "Write your try-catch-finally statement first. Write the test and force the exception. Create the exception classes needed.")

- Are there dedicated try/catch blocks that handle one specific concern, or are they catch-all blocks?

### Q5: Are classes small and cohesive?

(Martin Ch.10: "A class should have only one responsibility — one reason to change. Cohesion: a maximally cohesive class has every method using every member variable.")

- Pick the 3 largest classes. Write a 25-word description of each. Does it contain "and"?
- Are there subsets of methods that use only a subset of variables? If yes, split.
- Are constants declared before variables before methods? (Martin's ordering convention.)
- Are variables and utility methods private unless testing requires otherwise?

### Q6: Are boundaries clean?

(Martin Ch.8: "Keep boundaries clean between your code and third-party libraries. Wrap them with adapters. Write learning tests.")

- Is there an adapter/wrapper around third-party libraries, or are library types used directly in domain code?
- Are there learning tests that document the expected behavior of third-party dependencies?
- If the third-party library releases a breaking change, how many files would need to change? If more than 2, the boundary is not clean.

### Q7: Does the code obey the Law of Demeter?

(Hunt & Thomas: "Only talk to your immediate friends.")

- Is there method chaining like `obj.getA().getB().getC().doSomething()`? This couples the caller to the internal structure.
- Would changing an internal structure of one class break code in distant classes?

### Q8: Is the type system engaged or defeated?

- Count `any` / `as` casts / `# type: ignore` occurrences.
- Are public API boundaries typed?
- Is `strict` mode enabled? Is the type checker running in CI?

### Q9: Is there dead code, duplication, or inconsistency?

- Unused exports (`npx knip`, `vulture`, or manual check).
- Copy-pasted blocks of 10+ lines.
- Commented-out code.
- Mixed approaches: `fetch` + `axios` for API calls, `Date` + `dayjs` for dates, `process.env` scattered vs. config module.

### Q10: Is code formatted to reveal structure?

(Martin Ch.5: "Vertical density: lines of code that are tightly related should appear vertically dense. Vertical distance: how far do you have to hunt to find the concept you need?")

- Are closely-related functions and variables colocated, or scattered across the file?
- Is there unnecessary vertical space between logically connected lines?
- Are instance variables declared at the top of the class (so readers see them first)?
- Does a utility function appear immediately after its first use?

## Cross-Dimension Hooks

- If type safety is weak → tag `@root:no-types`
- If error handling is absent because no tests exist to catch failures → tag `@root:no-tests`
- If boundaries are dirty (third-party types leaking) → note this in Architecture findings
- If concurrency concerns are mixed with business logic → note this in Architecture findings
