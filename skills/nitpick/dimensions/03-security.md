# Security

Score how well the project protects against vulnerabilities and data exposure.

Before scoring, re-read `00-rubric.md` for severity definitions and score anchors.

> **Book sources**: *The Pragmatic Programmer* (Hunt & Thomas) for Design by Contract and crash-early; *Clean Code* Ch.7 for error propagation discipline.

Weight this dimension higher for services/APIs and lower for CLI tools or libraries that do not handle user data.

## Diagnostic Questions

### S1: Where are the secrets?

- `rg -i "password|secret|token|apikey|api_key" --type-not md` — inspect each match.
- Check `.gitignore` for `.env`. Is `.env` committed? Is there a `.env.example`?
- Are credentials hardcoded in config files, Dockerfile, CI scripts, or source code?
- Are they loaded from environment variables or a secrets manager?

Any hardcoded real credential is P0. A committed `.env` with real values is P0.

### S2: Are contracts enforced at boundaries?

(Hunt & Thomas: "Design by Contract — a program is correct only if it satisfies preconditions, postconditions, and invariants.")

For each public function/endpoint, check three things:

| Contract type | What to check | Example violation |
|---------------|--------------|-------------------|
| **Precondition** | What must be true before calling? Is it validated? | Function accepts `userId` without checking the caller is authorized |
| **Postcondition** | What does the function guarantee on return? | Function claims to return a `User` but can return `null` |
| **Invariant** | What must always be true about the object? | An `Account` object can exist with negative balance after a race condition |

Specific checks:

- Is input validated at the boundary, or does the system assume well-formed input?
- Are SQL queries parameterized, or is there string concatenation? (`rg "SELECT.*\+|SELECT.*\$\{" src/`)
- Is user input rendered without escaping (XSS risk)?
- Is file path construction vulnerable to `../../` traversal?
- Are schema validators (Zod, Joi, Pydantic) used at API boundaries, or manual `if` checks?

Missing validation on a public endpoint is P1. SQL injection is P0.

### S3: Does the system crash early?

(Hunt & Thomas: "Crash Early — a dead program normally does a lot less damage than a crippled one.")

- When an invariant is violated, does the system fail fast and loudly, or limp forward?
- Are there silent fallbacks that mask real errors (catch-all blocks returning defaults)?
- Is there object-level authorization (can user A access user B's data by changing an ID)?
- Are authentication checks enforced on every protected endpoint? List any that are not.
- Are auth tokens stored in httpOnly cookies or exposed in localStorage?
- Is there rate limiting on login/register/password-reset endpoints?

Missing object-level authorization is P0 (IDOR vulnerability).

### S4: What do the dependencies look like?

- Run `npm audit` / `cargo audit` / `pip-audit` / `go vuln` if possible.
- Are versions pinned (`package-lock.json` committed) or floating (`*`, `^`)?
- Are there deprecated packages?
- Are third-party libraries wrapped behind an adapter (Clean Code Ch.8: "Write learning tests to understand and control third-party boundaries")?

Known vulnerabilities in production dependencies are P1. No lockfile is P2.

### S5: Is sensitive data protected at rest and in transit?

- Are passwords hashed with bcrypt/argon2 (not MD5/SHA-256)?
- Are database connections using TLS if remote?
- Is PII or auth data being logged in plain text?
- Are CORS policies production-appropriate, or `*`?
- Are session/token expiry times reasonable?

## Cross-Dimension Hooks

- If no tests exist → tag `@root:no-tests` (security regressions go undetected)
- If no CI exists → tag `@root:no-ci` (no automated dependency scanning)
- If secrets are hardcoded because there is no config module → tag `@root:hardcoded-secrets`
- If contracts are not enforced because functions do not define preconditions → note this in Code Quality
