# Scoring Rubric

All dimensions share this rubric. Read it before reviewing any dimension.

> **Philosophy sources**: Ousterhout (*A Philosophy of Software Design*) for the strategic-vs-tactical lens; Hunt & Thomas (*The Pragmatic Programmer*) for broken-windows and good-enough calibration; Martin (*Clean Code*) for the definition of craft quality.

## Severity Levels

| Tag | Name | Definition | Action |
|-----|------|-----------|--------|
| P0 | Blocker | Will cause data loss, security breach, or production outage. Must fix before next release. | Fix immediately |
| P1 | Serious | Will cause bugs, performance degradation, or maintainability debt that compounds. Fix within a week. | Schedule this week |
| P2 | Should fix | Makes the codebase harder to change or reason about. Does not cause bugs today but will tomorrow. | Schedule this month |
| P3 | Nit | Style, naming, or minor inconsistency. Fix opportunistically. | Fix when touching the file |

(Ousterhout: "Complexity is incremental — it comes from the accumulation of small details, not from a single fundamental failure. Each shortcut adds a little, until the system becomes unmaintainable. Working code is not enough.")

Use P2 liberally for complexity-accumulating shortcuts. They are the slow-rotting kind of debt.

## Evidence Standard

Every finding MUST include:
- **File and line reference** (e.g. `src/api/client.ts:42`)
- **What** the problem is (one sentence)
- **Why** it matters (the consequence, not the principle)
- **How** to fix it (specific enough that someone could execute it)

(Hunt & Thomas: "Provide options, not lame excuses." A finding without a fix is an excuse.)

If you cannot provide a file and line reference, the finding is speculation. Tag it "needs verification" and move on.

## Score Anchors (0-10)

| Score | Anchor |
|-------|--------|
| 0 | Catastrophic: the dimension is not addressed at all; actively harmful |
| 2 | Severe: minimal effort, massive gaps, no awareness of the problem |
| 4 | Weak: awareness exists but implementation is inconsistent or superficial |
| 5 | Mediocre: baseline exists but has obvious holes |
| 6 | Decent: above average but with clear improvement areas |
| 7 | Good: solid practice with occasional lapses |
| 8 | Strong: consistent, well-reasoned practice across the codebase |
| 9 | Excellent: exemplary practice that most teams would learn from |
| 10 | Exemplary: the dimension is a competitive advantage; rare to find |

(Martin: "Clean code always looks like it was written by someone who cares. There is nothing obvious you can do to make it better." A score of 8+ means you cannot find obvious improvements.)

(Hunt & Thomas: "Good-enough software does not mean sloppy. Know when to stop." A score of 10 does not mean maximally engineered — it means appropriately engineered for the project's stage and audience.)

## Strategic vs Tactical Calibration

(Ousterhout: "Tactical programming: get it working, move on. Strategic programming: invest 10-20% of time in improving design. The difference compounds — tactical teams accumulate complexity, strategic teams keep it manageable.")

When scoring, consider: is this project being developed tactically (just working code) or strategically (continual small design investments)? A tactically-developed project with a 6/10 architecture score will degrade to 3/10 within a year unless the development approach changes.

## Broken Windows Check

(Hunt & Thomas: "Do not live with broken windows. One broken window starts the slide toward decay.")

Before finalizing scores, check: are there known-broken things being ignored? A single ignored broken window should subtract 1 point from the affected dimension (the team has demonstrated they tolerate decay).

## Cross-Dimension Signals

Some problems manifest across multiple dimensions. When you find one, tag it with a `@root` marker so the synthesis step can group them. Common patterns:

- `@root:no-tests` — missing tests cause low scores in Testing, Security (unverified auth), and DX (fear of refactoring)
- `@root:no-ci` — no CI causes low scores in Testing, DX, and Security (no dependency scanning)
- `@root:fat-controllers` — business logic in controllers causes low scores in Architecture, Code Quality, and Testing (untestable)
- `@root:no-types` — missing type safety causes low scores in Code Quality, Testing (harder to assert), and DX (poor autocomplete)
- `@root:hardcoded-secrets` — causes low scores in Security and DX (impossible to deploy safely)
- `@root:tight-coupling` — infrastructure details inside business logic cause low scores in Architecture, Testing (harder to substitute), and Performance/Security when transport or storage choices become fixed
- `@root:tactical-mode` — the team is developing tactically (no design investment); architecture, code quality, and DX all suffer slowly

Do not force a cross-dimension tag if the problem is genuinely isolated.
