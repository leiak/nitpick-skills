# C / C++

> **Book sources**: *Effective C++* (Scott Meyers); *Effective Modern C++* (Scott Meyers); *The C Programming Language* (Kernighan & Ritchie); *A Tour of C++* (Bjarne Stroustrup).

If the project is C or C++, read this file in addition to the six dimension files. Apply these language-specific questions.

## Resource Management

### CPP1: Is RAII used consistently?

(Meyers Item 13: "Use objects to manage resources. Put resources inside objects and rely on C++ destructor auto-invocation to ensure resources are released.")

- Are raw `new` / `delete` used instead of smart pointers (`std::unique_ptr`, `std::shared_ptr`)? Each raw `new` without a matching smart pointer is P1.
- Are `new` results stored in smart pointers in standalone statements? (Meyers Item 17: storing in the same statement as a function call risks resource leaks due to unspecified evaluation order.)
- Is `std::unique_ptr` preferred over `std::shared_ptr` (exclusive ownership is the common case)?
- Are circular references in `shared_ptr` avoided (use `std::weak_ptr` for back-references)?
- Are file handles, sockets, mutexes wrapped in RAII classes?

### CPP2: Are destructors safe?

(Meyers Item 7: "Declare destructors virtual in polymorphic base classes.")
(Meyers Item 8: "Prevent exceptions from leaving destructors.")

- Does every polymorphic base class have a virtual destructor? If not, deleting a derived object through a base pointer is undefined behavior.
- Do destructors swallow exceptions? (Wrap in try/catch, log, or call `std::abort()`.)
- Are virtual functions called during construction or destruction? (Meyers Item 9: this calls the base class version, not the derived — surprising and dangerous.)

### CPP3: Is copy behavior controlled?

(Meyers Item 5-6: "Know what functions C++ silently writes and calls. Explicitly disallow compiler-generated functions you do not want.")

- For resource-managing classes, is copy constructor and copy assignment defined, deleted, or defaulted correctly?
- Is the Rule of Five followed (destructor, copy constructor, copy assignment, move constructor, move assignment — define or delete all five)?
- Does the copy assignment operator handle self-assignment (`operator=` on itself)?

## Type Safety

### CPP4: Is `const` used maximally?

(Meyers Item 3: "Use const whenever possible.")

- Are function parameters declared `const` when they should not be modified?
- Are member functions declared `const` when they do not modify state?
- Are `const` iterators used when mutation is not needed?
- Are `constexpr` / `consteval` used for compile-time constants instead of `#define`? (Meyers Item 2: prefer consts, enums, and inlines to #defines.)

### CPP5: Is casting minimized?

(Meyers Item 27: "Minimize casting.")

- Are C-style casts `(int)x` used instead of C++ casts (`static_cast`, `dynamic_cast`, `const_cast`, `reinterpret_cast`)? C-style casts hide what is being done.
- Is `dynamic_cast` used sparingly? Frequent use suggests a design problem (should use polymorphism instead).
- Are there `reinterpret_cast` uses? Each must be justified.

## Modern C++

### CPP6: Are modern C++ features used?

(Meyers, *Effective Modern C++*: "Prefer auto to explicit type declarations. Use nullptr instead of 0 or NULL. Prefer scoped enums to unscoped enums.")

- Is `auto` used for type deduction where it improves readability?
- Is `nullptr` used instead of `NULL` / `0`?
- Are range-based for loops used instead of index-based loops?
- Are lambda expressions used instead of functors where appropriate?
- Is `std::move` used for transfer of ownership?
- Are `std::optional` / `std::variant` / `std::any` used for nullable/multi-type values?
- Are structured bindings used (`auto [key, value] : map`)?

### CPP7: Are concurrency primitives used correctly?

- Are `std::mutex` + `std::lock_guard` / `std::unique_lock` used instead of raw lock/unlock?
- Are `std::atomic` types used for simple shared variables?
- Is `std::thread` lifecycle managed (joined or detached before destruction)?
- Are condition variables used with predicates to avoid spurious wakeups?

## C-Specific

### CPP8: Is C code safe?

(For C or C-code-within-C++ projects)

- Are buffer sizes checked before `strcpy` / `memcpy` / `sprintf`?
- Are `const char*` used for immutable string parameters?
- Is `snprintf` used instead of `sprintf` (buffer overflow prevention)?
- Are pointers initialized (to `nullptr`/`NULL`) and checked before dereference?
- Are there `goto` statements? (Rarely justified; each is P2.)

## Cross-Dimension Hooks

- Raw `new`/`delete` without smart pointers → tag `@root:no-tests` (memory leaks are hard to catch without tests)
- Missing virtual destructor → note this in Security (undefined behavior)
- C-style casts → note this in Code Quality (type safety)
