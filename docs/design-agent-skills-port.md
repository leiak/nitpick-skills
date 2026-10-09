# Nitpick Enhancement Design: Porting Best Practices from agent-skills

## Background

This design document describes improvements to the Nitpick project based on
examination of Addy Osmani [agent-skills](https://github.com/addyosmani/agent-skills)
repository. Three high-priority capabilities have been identified:

1. **Trigger evaluation** - verify that Nitpick activates when users say
   "review this project" and does not activate for unrelated prompts.
2. **Anti-rationalization guards** - prevent the agent from skipping steps
   or producing shallow reports.
3. **Verification checklist** - ensure the agent self-checks report quality
   before declaring the review complete.

Additionally, two medium-priority capabilities are included:

4. **Slash commands** - provide short user-facing commands that invoke Nitpick.
5. **Cross-platform installation** - extend install coverage to Gemini CLI and
   OpenCode.

## Scope

| Item | Priority | Files touched |
|------|----------|---------------|
| Trigger eval (Tier 2) | High | `evals/cases/nitpick.json`, `scripts/run-evals.js`, `validate.ps1` |
| Anti-rationalization | High | `skills/nitpick/SKILL.md` |
| Verification checklist | High | `skills/nitpick/SKILL.md` |
| Slash commands | Medium | `.claude/commands/nitpick.md`, `commands/nitpick.toml` |
| Cross-platform install | Medium | `install.ps1`, `README.md`, `README.zh.md` |

## Design Details

### 1. Trigger Evaluation

#### Problem

Nitpick description in the YAML frontmatter is the only signal the agent
uses to decide whether to activate the skill. If the description lacks the
vocabulary users actually say (e.g. audit, code quality review, find
problems), the agent may not activate it. If the description is too broad,
it may trigger for unrelated prompts.

#### Solution

Add a deterministic, CI-safe trigger evaluation modeled on agent-skills
Tier 2 system:

```
evals/
  cases/
    nitpick.json
scripts/
  run-evals.js
```

The eval case file follows agent-skills schema:

```json
{
  "skill_name": "nitpick",
  "trigger": {
    "positive": [
      { "prompt": "Review this project", "top_k": 3 },
      { "prompt": "Nitpick this codebase", "top_k": 1 },
      { "prompt": "用中文审查这个项目", "top_k": 3 },
      { "prompt": "Audit the architecture and code quality", "top_k": 3 },
      { "prompt": "Critique my project and give me an upgrade roadmap", "top_k": 3 }
    ],
    "negative": [
      { "prompt": "Write a REST API endpoint", "owner": null },
      { "prompt": "Fix this TypeScript compilation error", "owner": null },
      { "prompt": "Generate unit tests for this function", "owner": null }
    ]
  }
}
```

`scripts/run-evals.js` performs a stemmed TF-IDF cosine similarity ranking of
the user prompt against the skill description. For positive prompts, Nitpick
must rank within `top_k`. For negative prompts, Nitpick must not rank first.
The script is zero-dependency (Node.js built-ins only) and exits 1 on any
failure, making it suitable for CI.

The script is a simplified single-skill version of agent-skills runner. It
does not need the full multi-skill routing collision detection because Nitpick
is a single-skill plugin. If future skills are added, the runner can be
extended.

#### Validation update

`validate.ps1` will be updated to:
- Check that `evals/cases/nitpick.json` exists and is valid JSON
- Check that at least 3 positive and 2 negative triggers are present

CI (`.github/workflows/validate.yml`) will run `node scripts/run-evals.js`
after `validate.ps1` passes.

### 2. Anti-Rationalization Guards

#### Problem

During long reviews, an agent may rationalize skipping steps: the project is
small, there is no need to check all six dimensions; enough context exists so
skip reading the language guide; this dimension is not relevant. These
shortcuts produce shallow, unreliable reports.

#### Solution

Add a `## Anti-Rationalization` section to `skills/nitpick/SKILL.md`, placed
after `## Tone & Principles`. Format follows agent-skills pattern:

| Rationalization | Reality |
|---|---|
| "This project is too small for a full review" | Small projects still benefit from architectural and DX findings. Scale effort, but never skip a dimension. |
| "I already know the codebase, I will skip reading source files" | File names are not evidence. Every finding needs file:line references from actual source code. |
| "This dimension is not relevant" | All six dimensions apply. If one yields no findings, explicitly state so with justification. |
| "I will skip the language-specific guide" | The guide contains checks the general dimensions cannot cover (language-specific anti-patterns, idiom violations). |
| "I will generate the report without reading all dimension files" | Skipping a dimension file means missing its diagnostic questions. Read every file. |
| "No CI found, I will note it but not score it" | Missing CI is a finding (P1 or P2), not an excuse to skip the Testing and DX reviews. |
| "The report template is too long, I will simplify it" | The template ensures consistency. Use it. Omitting sections hides findings. |

### 3. Verification Checklist

#### Problem

After generating the report, the agent has no structured way to verify that
the review was thorough. It may declare the review complete even when findings
lack evidence, the roadmap is not dependency-ordered, or the report template
was not followed.

#### Solution

Add a `## Verification` section to `skills/nitpick/SKILL.md`, placed after
`## Anti-Rationalization`:

```markdown
## Verification

Before declaring the review complete, confirm:

- [ ] All six dimension files were read
- [ ] Language-specific guide(s) were read (if a guide exists for the project language)
- [ ] Every finding includes file:line evidence
- [ ] Every finding includes what, why, and how-to-fix
- [ ] Cross-dimension signals are identified and grouped
- [ ] The report follows the template structure for the chosen language
- [ ] The roadmap is dependency-ordered (quick wins before structural before strategic)
- [ ] Scores are calibrated against the rubric anchors (not arbitrary)
- [ ] Systemic root causes are separated from individual symptoms
- [ ] The report is written to docs/reviews/YYYY-MM-DD-nitpick.md (or output inline if no file access)
```

### 4. Slash Commands

#### Problem

Users must type a natural-language prompt to invoke Nitpick. Slash commands
reduce friction and make the workflow discoverable.

#### Solution

Add command definitions following agent-skills dual format (Claude `.md` +
platform-agnostic `.toml`):

```
.claude/commands/nitpick.md
commands/nitpick.toml
```

**Claude command** (`.claude/commands/nitpick.md`):

Invoke the nitpick skill.

Perform a comprehensive project critique across all six dimensions:
architecture, code quality, security, performance, testing, and developer
experience. Read the shared rubric first, then apply each dimension
diagnostic questions to actual source code. Apply language-specific checks
if a guide exists for the project primary language.

Produce a structured report with scores, severity-ranked findings, cross-
cutting root causes, and a dependency-ordered upgrade roadmap. Write it to
`docs/reviews/YYYY-MM-DD-nitpick.md`.

**TOML command** (`commands/nitpick.toml`):

```toml
description = "Comprehensive project critique across six dimensions"

prompt = """
Invoke the nitpick skill.

Review the codebase across architecture, code quality, security,
performance, testing, and DX. Apply language-specific guides.
Produce a structured report with scores, findings, root causes,
and a dependency-ordered roadmap.
"""
```

### 5. Cross-Platform Installation

#### Problem

Nitpick currently installs to Claude Code and Codex only. Gemini CLI and
OpenCode are growing platforms that support skill-based workflows.

#### Solution

Extend `install.ps1` with two additional targets:

| Target | Destination |
|--------|-------------|
| `gemini` | `.gemini/skills/nitpick` (project) or `$env:USERPROFILE\.gemini\skills\nitpick` (global) |
| `opencode` | `.opencode/skills/nitpick` (project) or `$env:USERPROFILE\.opencode\skills\nitpick` (global) |

The `-Target` parameter accepts: `claude`, `codex`, `gemini`, `opencode`,
`all` (default: all four). Each target uses the same copy logic as existing
targets.

READMEs will be updated to document the new targets.

## Implementation Order

1. Anti-rationalization + verification checklist (pure markdown edits, no scripts)
2. Slash commands (new files, no changes to existing)
3. Trigger eval (new eval case + runner script + validate.ps1 update + CI update)
4. Cross-platform install (install.ps1 + READMEs)
5. Run full validation, update install copies, commit and push

## Success Criteria

- `validate.ps1` passes (all existing checks + new eval case checks)
- `node scripts/run-evals.js` passes (all positive triggers rank Nitpick within top_k; no negative trigger ranks it first)
- Skill copy in all 4+ installed locations contains the new sections
- Slash command is discoverable in Claude Code
- README documents all installation targets
