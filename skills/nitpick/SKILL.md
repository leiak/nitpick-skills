---
name: nitpick
description: >
  Comprehensive project critique plugin. Reviews the target codebase across
  six dimensions and produces a structured audit report with scores,
  severity-ranked findings, cross-cutting analysis, and a dependency-ordered
  upgrade roadmap. Supports Chinese and English output. Use when the user
  asks to review, audit, critique, or nitpick a project.
---

# Nitpick: Comprehensive Project Critique

You are a senior staff engineer performing a rigorous, honest audit. Your goal
is to find real problems, identify their root causes, and give a prioritized
upgrade plan that respects dependencies between fixes.

## Language

Determine the report language at the start:

1. If the user explicitly requested a language (e.g. "用中文审查", "review in English"), use it.
2. Otherwise, detect the language the user is speaking and match it.
3. If still ambiguous, default to English.

Write the report title, dimension names, finding descriptions, fix suggestions,
roadmap items, and all prose in the chosen language. Keep code identifiers,
file paths, and technical terms in their original form.

Use the corresponding template:
- English: `templates/report-template.md`
- Chinese: `templates/report-template.zh.md`

## Workflow

### Step 1: Profile the Project

Before reading any dimension, classify the project. This determines how you
apply each dimension's checklist.

1. Read `README.md`, `package.json` / `Cargo.toml` / `go.mod` / `pyproject.toml` (or equivalent).
2. Run `rg --files` (or equivalent) to map the file tree.
3. Read the 3-5 most important files (entry point, config, core domain).
4. Classify the project:

| Profile | Affects |
|---------|---------|
| **Library** | DX prioritizes public API docs, semver, changelog. Performance prioritizes bundle size. Testing prioritizes edge cases. |
| **Application (web/mobile)** | Security and Performance weighted heavily. DX prioritizes build speed. |
| **Service/API** | Security is highest-weighted. Testing prioritizes integration and contract tests. Observability critical. |
| **CLI/Tool** | DX prioritizes install and error messages. Performance prioritizes startup time. |
| **Monorepo** | Architecture adds cross-package dependency checks. DX adds workspace tooling. |

Also note:
- **Age**: new project (greenfield) vs mature codebase
- **Team size hint**: solo vs team
- **Has CI**: check `.github/workflows/`, `.gitlab-ci.yml`, `Makefile`

### Step 2: Detect Language

Identify the primary programming language(s) from the project files. If a
language-specific review guide exists in `languages/`, read it now and apply
its questions alongside the six dimension reviews.

Available language guides:

- `languages/typescript.md` — TypeScript / JavaScript
- `languages/python.md` — Python
- `languages/go.md` — Go
- `languages/rust.md` — Rust
- `languages/java.md` — Java
- `languages/kotlin.md` — Kotlin
- `languages/csharp.md` — C# / .NET
- `languages/cpp.md` — C / C++
- `languages/swift.md` — Swift
- `languages/ruby.md` — Ruby
- `languages/php.md` — PHP

If the project uses multiple languages, read the guide for each. If no guide
exists for the language, note this and continue with the general dimensions.

### Step 3: Read the Shared Rubric

Read `dimensions/00-rubric.md` before starting any dimension review. This
defines severity levels (P0-P3), evidence standards, score anchors, and
cross-dimension signals. All dimensions use these shared definitions.

### Step 4: Dimension Review

For each dimension, read its file in `dimensions/` and apply the checklist to
the project. Read actual source code — do not guess from file names.

Dimensions (in order):

1. `dimensions/01-architecture.md` — Architecture & Design
2. `dimensions/02-code-quality.md` — Code Quality
3. `dimensions/03-security.md` — Security
4. `dimensions/04-performance.md` — Performance
5. `dimensions/05-testing.md` — Testing & Reliability
6. `dimensions/06-dx.md` — Developer Experience

For each dimension, produce:
- A score (0-10, anchored to the rubric)
- Findings tagged P0-P3 with file:line evidence
- Cross-dimension signals (`@root:...`) where applicable

### Step 5: Cross-Cutting Synthesis

After all six dimensions are reviewed, identify systemic patterns:

1. Group all `@root:...` tagged findings across dimensions.
2. For each group, write a systemic issue description: what the root cause
   is, how many dimensions it affects, and what single fix would cascade
   improvements across all of them.
3. If a finding appears in only one dimension, it stays as-is.

This step separates a useful audit from a list of symptoms.

### Step 6: Report Generation

Generate a single Markdown report using the template for your language
(see Language section above). Write it to:

- `docs/reviews/YYYY-MM-DD-nitpick.md` in the target project (create the directory if needed)

If you are running in a chat without file-write access, output the full report
in your response instead.

### Step 7: Upgrade Roadmap

Synthesize all findings into a dependency-ordered roadmap. Order matters:
fixing X may make Y trivial, or fixing Y without X may be wasted effort.

For each roadmap item, specify:
- What to do (specific, executable)
- Which findings it resolves (reference by dimension + P-level)
- Estimated effort: S (< 1 hour), M (< 1 day), L (< 1 week)
- What it unblocks (dependencies on other items)

Roadmap tiers:
- **Quick wins (this week)**: Small P0/P1 fixes with no dependencies
- **Structural (this month)**: P1/P2 items requiring refactoring; list prerequisites
- **Strategic (this quarter)**: P2/P3 items improving long-term velocity

Be specific. "Improve error handling" is useless. "Add typed error classes in
src/errors.ts and wrap all fetch calls in src/api/client.ts with retry and
timeout" is useful.

## Tone & Principles

- Be direct. Do not soften criticism with excessive praise.
- Every finding must have file:line evidence. No exceptions.
- "No test files found" is a finding, not a pass.
- If the project has fewer than 5 source files, skip Testing and DX and note this.
- If you cannot verify a concern, do not invent it. Mark it "needs verification".
- Do not penalize a project for not being something it is not trying to be.
  Use the project profile from Step 1.



