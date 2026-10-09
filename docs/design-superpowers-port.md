# Nitpick Enhancement Design: Porting Best Practices from Superpowers

## Background

This design document describes improvements to the Nitpick project based on
examination of obra/superpowers repository. The three highest-impact
capabilities have been identified:

1. **Session-start bootstrap injection** - automatically tell the agent that
   Nitpick exists and when to use it, without requiring the user to mention
   the skill by name.
2. **Parallel dimension review prompts** - ready-made persona prompts that
   enable dispatching one sub-agent per dimension for concurrent review.
3. **Behavioral pressure testing** - verify that agents actually follow the
   Nitpick workflow under realistic conditions, not just that files exist.

## Scope

| Item | Priority | Files touched |
|------|----------|---------------|
| Session-start hook | High | `hooks/hooks.json`, `hooks/session-start` |
| Parallel review prompts | High | `skills/nitpick/prompts/` (4 new files) |
| Behavioral test scenarios | High | `evals/scenarios/` (2 new files) |
| Skill update | High | `skills/nitpick/SKILL.md` |

## Design Details

### 1. Session-Start Bootstrap Injection

#### Problem

Nitpick is installed as a skill directory, but the agent only discovers it
when the user explicitly says "nitpick" or "review this project". If the user
says "audit this codebase" or "find problems", the agent may not associate
those words with the Nitpick skill. Superpowers solves this by injecting a
bootstrap message at session start that teaches the agent to check for skills
before acting.

#### Solution

Add a Claude Code SessionStart hook that injects a short bootstrap message:

```
hooks/
  hooks.json
  session-start
```

**hooks/hooks.json:**

```json
{
  "hooks": {
    "SessionStart": [
      {
        "matcher": "startup|clear",
        "hooks": [
          {
            "type": "command",
            "command": "bash \"${CLAUDE_PLUGIN_ROOT}/hooks/session-start\"",
            "shell": "bash"
          }
        ]
      }
    ]
  }
}
```

**hooks/session-start** (bash script):

Reads `skills/nitpick/SKILL.md`, extracts the description, and outputs a JSON
`additionalContext` message:

```
<NITPICK-AVAILABLE>
The nitpick skill is available. Use it when the user asks to review, audit,
critique, or nitpick a project. Announce "Using nitpick skill" and follow
its workflow exactly. Do not skip dimensions. Do not skip the rubric.
</NITPICK-AVAILABLE>
```

This is a simplified version of Superpowers approach. It does not need the
full `using-superpowers` content (which teaches a general skill-discovery
pattern); it only needs to remind the agent that Nitpick exists and how to
invoke it.

#### Why not inject the full SKILL.md?

Superpowers injects the full `using-superpowers` skill because it is the
"meta-skill" that teaches the agent HOW to discover and use other skills.
Nitpick is a single-skill plugin, so injecting the full SKILL.md would waste
context tokens. A short reminder is sufficient.

### 2. Parallel Dimension Review Prompts

#### Problem

Nitpick currently reviews all six dimensions sequentially in a single agent
context. This is slow and can lead to shallow reviews when context window
pressure builds up. Superpowers solves this with subagent-driven development:
dispatch a fresh sub-agent per task with precisely crafted instructions.

#### Solution

Add a `prompts/` directory under `skills/nitpick/` with one prompt per
dimension, designed to be dispatched to sub-agents:

```
skills/nitpick/prompts/
  dimension-reviewer.md    # Generic template
  architecture.md
  code-quality.md
  security.md
  performance.md
  testing.md
  dx.md
```

**Generic template** (`dimension-reviewer.md`):

```markdown
You are reviewing a codebase for the [DIMENSION_NAME] dimension of a
comprehensive project critique.

## Your Task

1. Read the dimension checklist at `dimensions/[DIMENSION_FILE]`
2. Read the shared rubric at `dimensions/00-rubric.md`
3. Apply every diagnostic question to actual source code
4. Produce findings with file:line evidence

## Output Format

For each finding:
- P0/P1/P2/P3 severity tag
- File and line reference
- What the problem is (one sentence)
- Why it matters (the consequence)
- How to fix it (specific enough to execute)

Also provide:
- A score (0-10) calibrated to the rubric anchors
- Any cross-dimension signals (`@root:...`) you observed

## Rules

- Read actual source code. Do not guess from file names.
- Every finding needs file:line evidence. No exceptions.
- If a question yields no findings, explicitly state "no issues found".
- Do not soften criticism. Be direct.
```

Each dimension-specific prompt replaces `[DIMENSION_NAME]` and
`[DIMENSION_FILE]` with the actual values.

#### SKILL.md update

Add a new section after Step 4 (Dimension Review):

```markdown
### Step 4b: Parallel Review (Optional)

If subagent dispatch is available (Claude Code, Codex CLI, etc.), you may
dispatch one sub-agent per dimension using the prompt templates in
`prompts/`. Each sub-agent reviews one dimension independently and returns
findings + score. Merge results in the main agent.

Benefits: each dimension gets a fresh context window. No dimension is
shortchanged by context pressure.

If subagents are not available, review dimensions sequentially as before.
```

### 3. Behavioral Pressure Testing

#### Problem

The current trigger evaluation (`scripts/run-evals.js`) uses TF-IDF cosine
similarity, which verifies lexical overlap but not actual agent behavior. An
agent could match the description but still skip dimensions, soften criticism,
or omit file:line evidence. Superpowers solves this with scenario-based
behavioral tests using real LLM sessions.

#### Solution

Add two eval scenarios that verify agent behavior under pressure:

```
evals/scenarios/
  full-review-compliance.yaml
  small-project-no-skip.yaml
```

### Scenario 1: Full review compliance

- Setup: Create a small project with intentional P0/P1/P2 issues across
  multiple dimensions

- Prompt: "Nitpick this project"
- Expectations:
  - All six dimension files are read
  - Every finding has file:line evidence
  - Report follows template structure
  - Roadmap is dependency-ordered
  - Agent does not say "looks good" without evidence

### Scenario 2: Small project no-skip

- Setup: Create a minimal project (3 source files, no tests, no CI)
- Prompt: "Review this project"
- Expectations:
  - Agent does NOT skip Testing or DX dimensions
  - "No tests found" and "No CI found" are reported as findings
  - Agent scales effort but does not skip dimensions

#### Implementation note

These scenarios require a headless LLM runner (similar to Superpowers
`drill` harness or agent-skills Tier 3). They will not run in CI by default.
Add a `--behavioral` flag to `scripts/run-evals.js` that executes them
on-demand. Structural and trigger evals remain the CI gate.

### 4. SKILL.md Update

Add three improvements to `skills/nitpick/SKILL.md`:

**a. Parallel review section** (after Step 4, as described above)

**b. Iron Law for report quality** (in Tone & Principles):

```markdown
## Iron Law

NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE

Every finding needs file:line evidence from actual source code read in this
session. Every score must be calibrated to the rubric anchors. The roadmap
must be dependency-ordered. If you have not read a dimension file, you
cannot score it.
```

**c. Reviewer persona** (brief, in the header):

```markdown
You are a senior staff engineer performing a rigorous, honest audit. You
are NOT trying to be helpful. You are trying to find real problems.
Praise is not your job.
```

## Implementation Order

1. Add `hooks/` directory (hooks.json + session-start script)
2. Add `prompts/` directory (7 files: generic template + 6 dimensions)
3. Update SKILL.md (parallel review section + Iron Law + reviewer persona)
4. Add eval scenarios (2 YAML files)
5. Update validate.ps1 (check hooks and prompts exist)
6. Update READMEs (document hooks and parallel review)
7. Run validation, sync install copies, commit and push

## Success Criteria

- `validate.ps1` passes with new checks for hooks and prompts
- Session-start hook outputs valid JSON with Nitpick reminder
- Prompt templates contain correct dimension file references
- SKILL.md contains parallel review section, Iron Law, and reviewer persona
- All 8 installed copies contain updated SKILL.md and prompts
- Behavioral scenarios are documented but marked as on-demand (not CI)
