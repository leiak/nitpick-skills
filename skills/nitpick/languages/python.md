# Python

> **Book sources**: *Fluent Python* (Luciano Ramalho); *Effective Python* (Brett Slatkin).

If the project is Python, read this file in addition to the six dimension files. Apply these language-specific questions.

## Pythonic Idioms

### PY1: Is the code Pythonic or translated from another language?

(Ramalho: "Many experienced programmers try to bend Python to fit patterns they learned from other languages.")

- Are list comprehensions used instead of manual `for` + `append`?
- Are `enumerate()` and `zip()` used instead of manual index tracking?
- Are f-strings used instead of `.format()` or `%`?
- Are context managers (`with`) used for resource management instead of manual open/close?
- Are generators used for lazy evaluation instead of building full lists in memory?

### PY2: Are dunder methods implemented for custom classes?

(Ramalho: "The Python data model — special methods are the key to consistent behavior of objects.")

- Do custom classes implement `__repr__` for debugging?
- Are `__eq__` and `__hash__` implemented together (if one is defined, both must be)?
- Are `__len__`, `__iter__`, `__contains__` implemented where appropriate?
- Are dataclasses or `attrs` used for data-holding classes instead of manual `__init__`?

### PY3: Is mutability handled correctly?

(Ramalho: "Understand references, mutability, and recycling.")

- Are mutable default arguments used? (`def f(items=[])` is a classic bug — each call shares the same list.)
- Are mutable objects used as dict keys? (Only hashable/immutable types should be keys.)
- Is the difference between `is` and `==` respected?

## Type Hints

### PY4: Is gradual typing engaged?

- Are type hints present on public function signatures?
- Is `mypy` or `pyright` running in CI?
- Are there `# type: ignore` comments? Each is P2.
- Are `Protocol` classes used for structural typing instead of ABCs when appropriate?

### PY5: Are dataclasses and protocols used?

- Are `@dataclass` / `NamedTuple` used for data-holding classes?
- Are `Protocol` classes used for duck-typed interfaces?

## Error Handling

### PY6: Are exceptions specific and informative?

- Are bare `except:` or `except Exception:` used? (Always catch the narrowest exception type.)
- Are custom exception classes defined for domain errors?
- Are exception messages informative (include the value that caused the error)?

## Concurrency

### PY7: Is the right concurrency model chosen?

(Ramalho: "Use asyncio for I/O-bound, concurrent.futures for CPU-bound with processes, threading for I/O-bound with shared state.")

- Are there blocking calls inside `async` functions (they block the event loop)?
- Is the GIL considered for CPU-bound work?
- Are `asyncio.gather()` / `asyncio.TaskGroup` used instead of sequential awaits?

## Performance

### PY8: Are there Python-specific performance traps?

- String concatenation in loops (use `''.join()` instead).
- Repeated attribute lookups in hot loops (bind to local variable).
- `functools.lru_cache` missing on expensive pure functions.
- `collections.defaultdict` or `Counter` not used where appropriate.

## Cross-Dimension Hooks

- No type hints → tag `@root:no-types`
- Mutable default arguments → tag `@root:no-tests` (these create hidden shared state that makes testing unreliable)
- Blocking calls in async functions → note this in Performance (event loop blocking)
