# PHP

> **Book sources**: *Modern PHP* (Josh Lockhart); *PHP Objects, Patterns, and Practice* (Matt Zandstra); PHP-PSR standards.

If the project is PHP, read this file in addition to the six dimension files. Apply these language-specific questions.

## Modern PHP

### PHP1: Is modern PHP (7.4+/8.x) used?

- Are typed properties used (PHP 7.4+)?
- Are constructor property promotions used (PHP 8.0+)?
- Are enums used (PHP 8.1+) instead of class constants for fixed sets?
- Are readonly properties used (PHP 8.1+) for immutable data?
- Are named arguments used for readability instead of positional arguments?
- Are match expressions used instead of switch (PHP 8.0+)?

## Type Safety

### PHP2: Are strict types and type declarations used?

- Is `declare(strict_types=1)` present in every file?
- Are return types declared on all functions?
- Are parameter types declared?
- Are union types (`int|string`) used where appropriate (PHP 8.0+)?
- Is `mixed` used sparingly (it defeats type safety)?

## PSR Standards

### PHP3: Does the code follow PSR standards?

- PSR-1: Basic coding standard (files use `<?php` or `<?=` tags only, UTF-8, one class per file).
- PSR-4: Autoloading (namespace matches directory structure).
- PSR-12: Extended coding style (4-space indent, line length 120, opening braces on same line).
- PSR-3: Logger interface (`Psr\Log\LoggerInterface`).
- PSR-6/16: Caching interfaces.
- PSR-7/15: HTTP message / middleware interfaces.

## Error Handling

### PHP4: Are exceptions used instead of error suppression?

- Are `@` error suppression operators used? Each is P1 (silently hides errors).
- Are custom exception classes used for domain errors?
- Is `set_error_handler` / `set_exception_handler` configured?
- Are `try/catch` blocks specific (not catching bare `Exception`)?

## Security

### PHP5: Are PHP-specific security risks addressed?

- Are SQL queries parameterized (PDO prepared statements), never string-concatenated?
- Is output escaped with `htmlspecialchars()` / `htmlentities()` (XSS prevention)?
- Is `password_hash()` / `password_verify()` used instead of `md5()` / `sha1()`?
- Are file uploads validated (type, size, content)?
- Is `eval()` / `system()` / `exec()` avoided? Each is P0 unless absolutely necessary with sanitization.
- Are session cookies configured with `HttpOnly` and `Secure` flags?
- Is CSRF protection implemented?

## Framework Usage

### PHP6: Is the framework used idiomatically?

(Laravel / Symfony / etc.)

- Are dependency injection containers used instead of manual instantiation?
- Are ORM relationships loaded with eager loading (`with()` in Laravel) to avoid N+1?
- Are validation rules defined in Form Requests instead of controllers?
- Are migrations used instead of manual schema changes?
- Are environment variables accessed via config files, not `$_ENV` scattered in code?

## Cross-Dimension Hooks

- No `strict_types` → tag `@root:no-types`
- `@` suppression → note this in Security (errors hidden)
- N+1 ORM queries → note this in Performance
- Missing CSRF protection → P0 Security
