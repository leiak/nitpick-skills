[中文](README.zh.md) | English

# Nitpick

A comprehensive project critique plugin for Claude Code and Codex.

Nitpick audits your codebase across six dimensions, identifies systemic root causes, and produces a dependency-ordered upgrade roadmap.

## How It Works

```
Profile ──▶ Rubric ──▶ 6 Dimension Reviews ──▶ Cross-Cutting Synthesis ──▶ Report + Roadmap
  (Step 1)  (Step 2)      (Step 3)                  (Step 4)                    (Steps 5-6)
```

1. **Profile**: Classifies the project (library / app / service / CLI / monorepo) to adjust dimension weighting.
2. **Rubric**: A shared scoring framework defines P0-P3 severity, score anchors, and evidence standards.
3. **Dimensions**: Each dimension asks diagnostic questions against actual source code (not file names).
4. **Synthesis**: Cross-dimension signals are grouped into systemic root causes.
5. **Report**: Structured output with scores, findings, and a dependency-ordered roadmap (fix X before Y).

When subagent dispatch is available, each dimension can be reviewed by an
independent sub-agent with a fresh context window (see `prompts/`).

## Book Foundations

Each dimension is grounded in principles from classic software engineering books:

| Book | Author | Informs |
|------|--------|---------|
| *A Philosophy of Software Design* | John Ousterhout | Architecture: deep modules, complexity management, information hiding |
| *The Pragmatic Programmer* | Hunt & Thomas | Architecture (orthogonality, DRY), Security (Design by Contract), DX (broken windows) |
| *Clean Code* | Robert C. Martin | Code Quality: naming, functions, error handling, comments |
| *Systems Performance* | Brendan Gregg | Performance: USE method, RED method |
| *Growing Object-Oriented Software Guided by Tests* | Freeman & Pryce | Testing: testability as design, test pyramid |

## Dimensions

| # | Dimension | Diagnostic Focus |
|---|-----------|-----------------|
| 0 | Shared Rubric | Severity definitions, score anchors, evidence standard, cross-dimension signals |
| 1 | Architecture & Design | Deep vs shallow modules. Complexity accumulation. Information hiding. Orthogonality. DRY. Reversibility of infrastructure choices. |
| 2 | Code Quality | Naming intent. Function design. Comments. Error handling. Class cohesion. Boundaries. Type safety. |
| 3 | Security | Design by Contract. Secrets. Input validation. Auth/authz. Dependencies. Data protection. |
| 4 | Performance | USE method. RED method. N+1 queries. Caching. Network efficiency. Memory. |
| 5 | Testing & Reliability | Test pyramid. Test quality. Mock preference. Anti-patterns. CI. Graceful degradation. Observability. |
| 6 | Developer Experience | Time to first change. Broken windows. Tracer bullets. Good-enough calibration. CI. Docs freshness. |

## Language
## Language-Specific Reviews

Beyond the six general dimensions, Nitpick applies language-specific diagnostic questions derived from each language's classic books:

| Language | Book Source | Key Checks |
|----------|-------------|-----------|
| TypeScript / JavaScript | *Effective TypeScript* (Vanderkam), *Programming TypeScript* (Cherny) | Type safety, discriminated unions, no `any`, DI, async patterns |
| Python | *Fluent Python* (Ramalho), *Effective Python* (Slatkin) | Pythonic idioms, dunder methods, mutable defaults, type hints, GIL awareness |
| Go | *Effective Go*, *100 Go Mistakes* (Harsanyi), Go Proverbs | Small interfaces, error wrapping, context propagation, goroutine leaks, race detector |
| Rust | *The Rust Programming Language*, *Rust for Rustaceans* (Gjengset), *Zero to Production* (Palmieri) | Ownership, borrowing, `unwrap()` avoidance, trait design, newtypes, async pitfalls |
| Java | *Effective Java* (Bloch), *Java Concurrency in Practice* (Goetz) | Builder pattern, immutability, DI, generics, try-with-resources, concurrency |
| Kotlin | *Kotlin in Action*, Kotlin docs | Null safety (no `!!`), coroutines, structured concurrency, sealed classes, scope functions |
| C# / .NET | *C# in Depth* (Skeet), *CLR via C#* (Richter), *Adaptive Code* (Hall) | Nullable reference types, LINQ deferred execution, async/await correctness, records, Span/Memory |
| C / C++ | *Effective C++* (Meyers), *Effective Modern C++* (Meyers), K&R | RAII, smart pointers, virtual destructors, Rule of Five, `const` correctness, modern C++ |
| Swift | *The Swift Programming Language*, Protocol-Oriented Programming (WWDC) | Protocols over inheritance, value types, optional safety, retain cycles, Swift Concurrency |
| Ruby | *Practical Object-Oriented Design* (Metz), *Well-Grounded Rubyist* (Black) | Single responsibility, dependency injection, duck typing, metaprogramming, N+1 queries |
| PHP | *Modern PHP* (Lockhart), PSR standards | `strict_types`, PSR compliance, prepared statements, `@` suppression, framework idioms |

Nitpick supports Chinese and English report output.

- **Auto-detect**: The agent matches your language. If you write in Chinese, the report is in Chinese.
- **Explicit**: Ask "用中文审查" for Chinese or "review in English" for English.
- Default fallback is English.

## Install

### Claude Code

```powershell
# Project-level
Copy-Item -Recurse skills\nitpick .claude\skills\nitpick

# Or globally
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.claude\skills\nitpick"
```

### Codex

```powershell
# Project-level
Copy-Item -Recurse skills\nitpick .agents\skills\nitpick

# Or globally
Copy-Item -Recurse skills\nitpick "$env:USERPROFILE\.agents\skills\nitpick"
```

Or run the installer:

```powershell
.\install.ps1              # installs to all platforms (default)
.\install.ps1 -Target claude
.\install.ps1 -Target codex
.\install.ps1 -Target gemini
.\install.ps1 -Target opencode
```

## Hooks

A SessionStart hook (Claude Code) injects a brief reminder that the Nitpick
skill is available, so the agent proactively uses it when the user asks to
review or audit a project.

## Usage

Ask your agent:

- "Nitpick this project"
- "Audit this codebase"
- "Review the architecture and code quality"
- "用中文审查这个项目"

The agent will profile the project, apply all six diagnostic checklists, identify cross-cutting root causes, and write a report to `docs/reviews/YYYY-MM-DD-nitpick.md`.

## Report Structure

```
1. Overall Score (weighted by project profile)
2. Dimension Scores table
3. Systemic Issues (root causes spanning multiple dimensions)
4. Findings (per-dimension, P0-P3, with file:line evidence)
5. Upgrade Roadmap
   - Quick wins (this week) — small, dependency-free
   - Structural (this month) — refactoring with prerequisites
   - Strategic (this quarter) — long-term velocity improvements
```

Every finding includes: what the problem is, why it matters, a concrete fix, and a file:line reference. Every roadmap item includes: what to do, what it resolves, estimated effort (S/M/L), and what it unblocks.

## Project Structure

```
nitpick/
├── skills/
│   └── nitpick/
│       ├── SKILL.md              # Orchestrator: workflow, profiling, synthesis
│       └── dimensions/
│           ├── 00-rubric.md      # Shared scoring framework
│           ├── 01-architecture.md
│           ├── 02-code-quality.md
│           ├── 03-security.md
│           ├── 04-performance.md
│           ├── 05-testing.md
│           └── 06-dx.md
│       └── templates/
│           ├── report-template.md
│           └── report-template.zh.md
├── templates/
│   ├── report-template.md
│   └── report-template.zh.md
├── install.ps1                   # One-command installer
├── validate.ps1                  # Automated cross-reference validation
└── README.md
```

## License

MIT


