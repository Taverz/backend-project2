---
name: code-review
version: 2.0.0
description: |
  Multi-stream code review agent. Diff-aware: only inspects what changed in the current branch
  against the specified target branch. Runs THREE independent review streams in parallel:
  (A) full specialist stack on a primary model, (B) the same specialist stack on a different
  model — independent second opinion, (C) a naive researcher with no checklists for fresh-eye
  catches. A cross-model codex pass adds a fourth voice. A synthesizer sub-agent reconciles
  all four sources, marks consensus / majority / unique findings, and surfaces research
  discrepancies (where streams disagreed or one stream missed something). Validates code
  through the project's linter / analyzer / tests. Generates a structured markdown report
  with five severity levels (Blocker / Critical / Major / Minor / Info) — every finding
  from every stream is preserved and labeled with its cross-stream support. Self-improves
  through confidence calibration based on user verdicts. Trigger when the user asks:
  "code review", "review my branch", "check my diff", "code-review", or invokes /code-review
  explicitly.
allowed-tools:
  - Bash
  - Read
  - Write
  - Edit
  - Glob
  - Grep
  - AskUserQuestion
  - WebSearch
  - Agent
triggers:
  - code review
  - review my branch
  - check my diff
  - code-review
---

# /code-review — Ultimate Code Review Agent

You are the conductor of a **multi-stream code review**. Your job is to replace manual
review by running three *independent* review streams against the same diff, then reconciling
their findings into a single trustworthy report. You do not perform the reviews yourself —
you orchestrate sub-agents.

**The three streams (run in parallel):**

| Stream | Role | Equipment | Model |
|--------|------|-----------|-------|
| **A** — primary | Full specialist stack (conventions / correctness / mobile-security / overengineering), with project rules + docs | `opus` |
| **B** — second opinion | Identical specialist stack to A, **but on a different model** so its perspective is genuinely independent | `sonnet` |
| **C** — naive researcher | No checklists, no project rules, no docs — just the diff and "find what's wrong" | `sonnet` |

A fourth voice — **codex** (external CLI) — runs once if available.

After all four sources finish, a **synthesizer** sub-agent (Phase 7a) reconciles findings,
labels each by cross-stream support (consensus / majority / unique), and explicitly surfaces
*research discrepancies* — places where streams disagreed or where one stream made a claim
about a region another stream covered without flagging.

**Core principles:**
1. **Diff-aware** — never review files outside the diff except when context is required (a
   base class, an importer file). Even then, scope reads narrowly.
2. **Concrete over fluff** — every finding has a file, a line, a reason, a fix. "This could
   be better" is not a finding.
3. **Confidence is cross-stream support.** Synthesis upgrades findings supported by multiple
   streams and downweights singletons — but **never deletes findings**. The user explicitly
   wants every flagged issue surfaced (with its support level visible).
4. **You do not modify production code** — you only generate the report. Never call
   `Edit`/`Write` against project source files.
5. **You do not perform the review yourself.** Stream A, B, C, and the synthesizer are all
   `Agent` calls. Inline reasoning ("I'll just look at the diff myself") is forbidden — the
   manifest gate makes this visible and blocks the report.
6. **Do not invent things** — if you have not read a file, do not flag it. Read first, then
   judge.

---

## ⛔ HARD INVARIANTS (machine-checked)

Every run is tracked in a per-run **manifest** under `.claude-reviews/.runs/<RUN_ID>/manifest.json`.
The manifest is the single source of truth for whether each phase actually executed.
At the start of Phase 8 you **MUST** call `validate-run.sh`; if it exits non-zero, the
report **MUST NOT** be written. There is no override path — fix the missing steps and re-run.

**Workflow contract:**

1. Phase 0 begins by calling `init-run.sh`. This is the FIRST mandatory bash call.
   Without an active manifest, every other helper script refuses.
2. After every meaningful action in Phases 1–7, you MUST call
   `record-step.sh <subcommand> ...` to log it. The list of mandatory records is at the
   end of each phase under "**Manifest gate**".
3. Phase 8 begins with `validate-run.sh`. If it FAILS, you **stop**, fix the gap (run the
   skipped phase / record the missed step), and re-validate. You do not write the report
   bypassing this gate.

**FORBIDDEN — these patterns invalidate the run:**

- 🚫 **Inline analysis instead of Agent dispatch in Phase 5.** You MUST call the `Agent`
  tool for each specialist in each stream. Doing the work "in your head" and writing
  findings yourself is not allowed.
- 🚫 **Running fewer than 3 streams in `default` mode.** Validator requires Stream A ≥2
  specialists, Stream B ≥2 specialists, Stream C ≥1 naive researcher. A and B MUST use
  different `model:` parameters in the Agent call.
- 🚫 **Inline synthesis in Phase 7a.** Cross-stream reconciliation MUST go through a
  separate `Agent` call. The synthesizer is its own role — see
  `specialists/synthesizer.md`. Validator requires `synthesis-dispatched`.
- 🚫 **Suppressing findings before report.** Synthesis labels findings (consensus / unique
  / disagreement) but never deletes them. The user explicitly asked for every flagged
  issue to surface in the report. Confidence demotion → suppression appendix is fine
  (existing behavior); cross-stream singleton ≠ suppression.
- 🚫 **Skipping Phase 1 question (D1).** `record-step d1-asked <method>` MUST be called.
  Even if you pick the default branch silently, record `d1-asked default`.
- 🚫 **Reading 0 doc files when `doc/` exists.** If the project has a `doc/` or `docs/`
  directory with `.md` files, you MUST read at least one and call `record-step doc-read <path>`.
- 🚫 **Writing the report without `validate-run.sh` exiting 0** in the same session.
- 🚫 **Inventing manifest entries.** Only record steps you actually performed. `doc-read`
  for a path you didn't open with the `Read` tool is fabrication.

**Why the gates exist:** prose instructions ("you MUST do X") get rationalized away when
context is tight or the diff looks small. The manifest+validator make skipping visible —
the report cannot be written silently. Multi-stream specifically catches *research errors*:
when A flags X but B and C cover the same code without flagging, the synthesizer surfaces
that as a discrepancy for the user to arbitrate.

**Quick reference:**

```bash
# Phase 0 — first call, always
RUN_ID=$(bash ~/.claude/skills/code-review/bin/init-run.sh)

# After each step
bash ~/.claude/skills/code-review/bin/record-step.sh <subcommand> [args...]

# Phase 8 gate — refuses if any invariant is violated
bash ~/.claude/skills/code-review/bin/validate-run.sh
```

For the full subcommand list run `record-step.sh` with no args, or read the script header.

---

## Phase 0: Preflight

### Step 0.1: Working tree check

```bash
git status --porcelain | head -20
git rev-parse --show-toplevel
```

If there are uncommitted changes, this does not block the review (we only read), but warn
the user:

> "You have uncommitted changes. They will NOT be part of the review — I only look at what's
> committed against the target branch. Want to commit first, or proceed?"

Don't use AskUserQuestion here — it's just a warning. If the user wants to stop, they will.

### Step 0.2: Tool detection

```bash
# Codex for cross-model second opinion
which codex 2>/dev/null && echo "CODEX: yes" || echo "CODEX: no"

# Current branch
git rev-parse --abbrev-ref HEAD

# Default branch on origin
git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's|refs/remotes/origin/||' || echo "main"

# GitHub CLI (for PR-aware base detection)
gh auth status 2>/dev/null && echo "GH: yes" || echo "GH: no"
```

Remember these values — they're used downstream.

### Step 0.3: Create reports directory

```bash
mkdir -p .claude-reviews
# Add to .gitignore if not already there
if [ -f .gitignore ] && ! grep -q "^\.claude-reviews" .gitignore; then
  echo ".claude-reviews/" >> .gitignore
fi
```

### Step 0.4: Initialize the run manifest (MANDATORY)

This is the first hard gate. Without a manifest, downstream helpers refuse and Phase 8
will fail validation.

```bash
RUN_ID=$(bash ~/.claude/skills/code-review/bin/init-run.sh)
echo "Run: $RUN_ID"
```

**Manifest gate (Phase 0):**
```bash
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 0_preflight
```

---

## Phase 1: Branch Context

Confirm with the user via AskUserQuestion D1:

**Title:** `D1 — Which branches are we comparing?`

**Body:**
> You're on branch `<current_branch>`. The default branch on origin is `<default>`.
> If there's an open PR, the target is usually that PR's base.
>
> Which branch should I use as target (the branch your code merges into)?

**Options:**
- A) `<default>` (default) — recommended for feature branches
- B) Specify manually — I'll ask next
- C) Use the base from an open PR (if `gh` is available)

**Recommendation:** A, if a default exists and is different from the current branch.

If **B** is chosen: ask a follow-up AskUserQuestion with an open answer — the user types
the branch name. Verify with `git rev-parse --verify <branch>`. If the branch doesn't exist
locally, try `origin/<branch>`. If neither resolves, ask again.

If **C** is chosen: run `gh pr view --json baseRefName -q .baseRefName`. If it returns,
use it. If it errors / no PR, fall back to A.

**Set these variables** for downstream use:
- `BASE_BRANCH` — target (e.g., `main` or `release/v4.6.0`)
- `CURRENT_BRANCH` — branch under review
- `MERGE_BASE` — branch point: `git merge-base "$BASE_BRANCH" "$CURRENT_BRANCH"`

If `MERGE_BASE` doesn't resolve (the branches diverged too much, or the target isn't fetched
locally) — ask the user to run `git fetch origin` and retry.

**Manifest gate (Phase 1):**
```bash
# After D1 is asked (or default chosen). <method> ∈ {ask, default, gh, manual}.
bash ~/.claude/skills/code-review/bin/record-step.sh d1-asked <method>
bash ~/.claude/skills/code-review/bin/record-step.sh set-base "$BASE_BRANCH" "$MERGE_BASE"
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 1_branch_context
```

---

## Phase 2: Project Context + Doc Gate

### Step 2.1: Read CLAUDE.md

```bash
[ -f CLAUDE.md ] && echo "CLAUDE_MD: yes" || echo "CLAUDE_MD: no"
```

If CLAUDE.md exists — read it fully (Read tool). Extract:
- Project stack (Flutter / React / Go / etc.)
- Architectural rules (Clean Architecture / MVVM / etc.)
- Naming conventions
- Validation commands (lint / test / build)
- Documentation links

### Step 2.2: Doc Gate

Look for documentation references in CLAUDE.md. Match any of these patterns:
- A `## Documentation` or `## Docs` section
- Links to `doc/`, `docs/`, `documentation/`
- Markdown links like `[...](doc/...)` or `[...](docs/...)`
- Phrases like "detailed docs are in", "full documentation:"

```bash
grep -iE "## (Documentation|Docs)|doc/|docs/|documentation/" CLAUDE.md 2>/dev/null
```

**If found** — proceed silently. Read up to 5 doc files (max 500 lines each), prioritizing
indexes / tables of contents. Be economical with context.

**If NOT found** — check the skill config:

```bash
[ -f .claude-reviews/.config.json ] && cat .claude-reviews/.config.json
```

If the config already has `"docs_path"` — use it without asking.

If neither CLAUDE.md nor the config has a docs path — ask AskUserQuestion D2:

**Title:** `D2 — Where is the project documentation?`

**Body:**
> CLAUDE.md doesn't reference any documentation. Documentation helps me understand
> architectural rules and conventions. Where can I find it?

**Options:**
- A) In `doc/` (or `docs/`) — auto-detect, if the directory exists
- B) Specify a path — I'll enter it manually
- C) No documentation exists / don't use any — review based only on CLAUDE.md and the code

**Recommendation:** A, if a `doc/` or `docs/` directory physically exists in the repo.

After the answer, save to `.claude-reviews/.config.json`:
```json
{
  "docs_path": "doc/development",
  "set_at": "2026-04-27T10:00:00Z",
  "branch_set_in": "refactor/adding-ultimate-tests"
}
```

For **A**: try reading index files (`README.md`, `INDEX.md` in the docs directory) and build
a map of what's there.

### Step 2.3: Extract project rules

From the gathered context (CLAUDE.md + docs), produce a short internal "project rules" block
that will be passed to every specialist. Bullet format:

```
PROJECT RULES (extracted from CLAUDE.md + docs):
- Stack: Flutter 3.x with BLoC + Drift + InheritedWidget DI
- Architecture: Clean Architecture (data/domain/presentation per feature)
- BLoC pattern: sealed classes with $ separator (MyState$Loading)
- Scopes instead of BlocProvider (EphemeralScope + AppScope)
- DTO classes: @immutable, const constructor, with serializer/mapper static fields
- File naming: snake_case with type suffix (user_screen.dart)
- Line length: 120
- Spacing: FillerVertical/Horizontal instead of SizedBox in Row/Column
- Container alternative: ColoredBox/DecoratedBox/Padding for single-property cases
- Class member order: constructors → static → fields → getters → methods
- Validation: make lint, make test, make gen
```

This block is fed to specialists in Phase 5.

**Manifest gate (Phase 2):**
```bash
# When you actually used the Read tool on CLAUDE.md:
bash ~/.claude/skills/code-review/bin/record-step.sh claude-md-read

# For EACH doc file you actually read with the Read tool:
bash ~/.claude/skills/code-review/bin/record-step.sh doc-read doc/development/<file>.md

# When you've produced the PROJECT RULES block:
bash ~/.claude/skills/code-review/bin/record-step.sh rules-extracted
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 2_doc_gate
```

> 🚫 **Do NOT** record `doc-read` for files you didn't open with the `Read` tool.
> If `doc/` exists with `.md` files, the validator requires ≥1 real read. The
> minimum is 1, but for a stack you don't know cold, read the index plus 2–4
> topical files relevant to the diff (BLoC, DTO, repository, etc.).

---

## Phase 3: Validation

### Step 3.1: Detect validation commands

Run `bash ~/.claude/skills/code-review/bin/detect-validation.sh` — it returns JSON with
detected commands. If the script is unavailable, fall back to manual detection:

- **Flutter:** `[ -f pubspec.yaml ]` → `dart analyze`, `flutter test`
- **Makefile:** `grep -E "^(lint|test|analyze):" Makefile` → use make targets
- **Node:** `package.json` → `npm run lint`, `npm test` (parse `scripts`)
- **Python:** `pyproject.toml` or `requirements.txt` → `ruff check`, `pytest`
- **Go:** `go.mod` → `go vet ./...`, `go test ./...`

If CLAUDE.md has a `## Health Stack` or `## Validation` section, that takes priority.

### Step 3.2: Run them

Run sequentially (not parallel — they may contend on the filesystem):

```bash
# Example. Real commands come from detection.
START=$(date +%s)
make lint 2>&1 | tail -100 > .claude-reviews/.tmp-lint.log
EXIT_LINT=$?
END=$(date +%s)
echo "LINT: exit=$EXIT_LINT duration=$((END-START))s"
```

Save each step's output to `.claude-reviews/.tmp-{lint|test|analyze}.log`. These logs are
passed to specialists as context.

**Rules:**
- If a command isn't available in the project — `SKIPPED`, don't flag it.
- If a command fails with a non-zero exit code — DO NOT block the review, but record
  `validation_failed: true` and surface it in a dedicated section above the findings.
- If a command hangs > 3 minutes — kill it and mark `TIMEOUT`.

### Step 3.3: Decide whether to proceed

If **the analyzer fails on compilation errors** (not lint warnings, real compile errors) —
ask AskUserQuestion D3:

**Title:** `D3 — Analyzer reports compilation errors`

**Body:**
> Running `dart analyze` (or equivalent) returned compilation errors:
>
> ```
> <first 10 lines of errors>
> ```
>
> What do you want to do?

**Options:**
- A) Continue review — I'll surface the errors as blockers in the report (recommended)
- B) Abort — I'll fix and re-run

**Recommendation:** A. Compile errors are findings, not noise.

For lint / test warnings — proceed without prompting; just include them as context.

**Manifest gate (Phase 3):**
```bash
# After EACH validation step. <kind> ∈ {lint, analyzer, test};
# <status> ∈ {pass, fail, skipped, timeout}.
bash ~/.claude/skills/code-review/bin/record-step.sh validation lint <status> <duration_s>
bash ~/.claude/skills/code-review/bin/record-step.sh validation analyzer <status> <duration_s>
bash ~/.claude/skills/code-review/bin/record-step.sh validation test <status> <duration_s>
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 3_validation
```

> If a command isn't available in the project — record `skipped`. The validator
> requires at least ONE of the three to be recorded with any status (skipped is OK).
> Silently doing nothing fails the gate.

---

## Phase 4: Diff Scoping

### Step 4.1: Get the diff

```bash
# Files changed in branch vs target
git diff "$MERGE_BASE"..HEAD --name-only > .claude-reviews/.tmp-files.txt

# Full diff (for specialists)
git diff "$MERGE_BASE"..HEAD > .claude-reviews/.tmp-diff.patch

# Stat for size estimation
git diff "$MERGE_BASE"..HEAD --stat | tail -1

# Commits on the branch
git log "$MERGE_BASE"..HEAD --oneline
```

### Step 4.2: Classify files

Tag each file from `.tmp-files.txt`:

| Tag | Pattern | Action |
|-----|---------|--------|
| `generated` | `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `lib/generated/`, `*.pb.go`, `*.gen.ts` | **SKIP** — never reviewed |
| `lock` | `pubspec.lock`, `package-lock.json`, `yarn.lock`, `Cargo.lock` | **SKIP** |
| `data` | path contains `/data/` (DTOs, repositories, mappers) | review with focus on network / serialization |
| `domain` | path contains `/domain/` (BLoCs, models, services) | review with focus on business logic |
| `presentation` | path contains `/presentation/` (screens, components, scopes) | review with focus on UI/UX and leaks |
| `test` | `test/`, `_test.dart`, `_test.go`, `.spec.ts` | light review — patterns and coverage |
| `migration` | `drift_schemas/`, `migrations/`, `*.sql` | **separate Data Migration check** |
| `config` | `*.yaml`, `*.json`, `*.toml`, `Dockerfile`, `Makefile`, `pubspec.yaml` | review with focus on security |
| `ci` | `.github/`, `.gitlab-ci.yml`, `.circleci/` | review with focus on security |
| `docs` | `*.md`, `doc/`, `docs/` | light review — style and consistency |
| `assets` | `assets/`, `images/`, `*.png`, `*.svg` | **SKIP** typically |

Count diff size excluding generated/lock/assets — that's the working volume.

### Step 4.3: Pick specialists based on volume

Decide which specialists to dispatch. Default logic:

| Condition | Specialists |
|-----------|-------------|
| ANY non-generated files | conventions (always-on) |
| `data/`, `config`, `ci`, network code | mobile-security |
| `domain/`, `presentation/`, any logic | correctness |
| Diff > 50 lines OR new abstractions | overengineering |
| Diff < 20 lines (trivial fix) | conventions + correctness only |

User-supplied force flags in the original prompt have priority:
- `--security` → force mobile-security
- `--all-specialists` → run all four regardless of size
- `--no-codex` → skip cross-model

Tell the user in one line:

> "Diff: 12 files (+234/-45), 4 generated skipped. Dispatching 4 specialists in parallel
> + codex review for second opinion. ETA ~2-3 min."

**Manifest gate (Phase 4):**
```bash
bash ~/.claude/skills/code-review/bin/record-step.sh diff-stat <files_total> <files_reviewed>
bash ~/.claude/skills/code-review/bin/record-step.sh specialists-planned conventions,correctness,mobile-security,overengineering
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 4_diff_scoping
```

---

## Phase 5: Multi-Stream Specialist Dispatch

> ⛔ **FORBIDDEN — read carefully.** This phase MUST go through the `Agent` tool.
>
> - In `default` mode you launch **THREE streams** in parallel: A (primary),
>   B (independent second-opinion on a different model), C (naive researcher).
> - Stream A and Stream B MUST use **different** `model:` parameters in the
>   Agent call. The validator rejects A and B sharing a model.
> - You MUST NOT inline the review ("I'll just analyze the diff myself").
> - You MUST call `record-step.sh agent-dispatched <task_id> <specialist> <stream>`
>   for EACH Agent dispatch.
>
> **Why so strict.** Two models running the same checklist produce genuinely
> different findings; the synthesizer in Phase 7a uses the divergence to detect
> hallucinations and missed bugs. If both streams secretly run the same model,
> the cross-check is fake.

### Step 5.0: Mode declaration

First, decide and record the run mode:

```bash
# Default — A + B + C + codex (full multi-stream)
bash ~/.claude/skills/code-review/bin/record-step.sh mode default

# Quick — A + C only (skip B and codex). User must say "quick" or pass --quick.
# bash ~/.claude/skills/code-review/bin/record-step.sh mode quick
```

### Step 5.1: Preparation

Read the specialist files:
- `~/.claude/skills/code-review/specialists/conventions.md`
- `~/.claude/skills/code-review/specialists/mobile-security.md`
- `~/.claude/skills/code-review/specialists/correctness.md`
- `~/.claude/skills/code-review/specialists/overengineering.md`
- `~/.claude/skills/code-review/specialists/naive-researcher.md` (Stream C)

Read the default checklist if the stack matches:
- Flutter/Dart → `~/.claude/skills/code-review/checklists/flutter-bloc.md`

Read prior calibration (if any):

```bash
[ -f ~/.claude/code-review/calibration.jsonl ] && \
  bash ~/.claude/skills/code-review/bin/apply-calibration.sh "$(basename $(pwd))"
```

The script returns fingerprints whose history says "frequent FP" or "frequent confirmed".
Pass these to specialists as hints (Stream A and B only — Stream C runs without calibration).

### Step 5.2: Pick model assignment

Default model assignment for the three streams:

| Stream | Model param | Rationale |
|--------|-------------|-----------|
| **A** | `opus` | Primary deep review with full context |
| **B** | `sonnet` | Independent second-opinion on a different model — catches A's blind spots |
| **C** | `sonnet` | Naive role; doesn't need the strongest model |

Synthesizer in Phase 7a runs on `opus`.

Record the chosen models BEFORE dispatching:

```bash
bash ~/.claude/skills/code-review/bin/record-step.sh stream-model A opus
bash ~/.claude/skills/code-review/bin/record-step.sh stream-model B sonnet
bash ~/.claude/skills/code-review/bin/record-step.sh stream-model C sonnet
```

If the user explicitly requested a different pairing (e.g. "swap A and B"), use
that — but A and B must remain distinct.

### Step 5.3: Parallel dispatch — ONE message, many Agent blocks

**Launch ALL streams in a single message** (multiple `Agent` tool blocks at once).
Tag each Agent's `description` with the stream label so you can match task_ids
back to streams.

#### Stream A (4 Agent calls — one per specialist)

For each specialist in `[conventions, correctness, mobile-security, overengineering]`:

```
Agent(
  subagent_type="general-purpose",
  model="opus",
  description="[A/conventions] specialist review",   # vary the specialist
  prompt=<<see equipped prompt template below>>
)
```

#### Stream B (4 Agent calls — same specialists, different model)

For each specialist in `[conventions, correctness, mobile-security, overengineering]`:

```
Agent(
  subagent_type="general-purpose",
  model="sonnet",                                      # ← MUST differ from A
  description="[B/conventions] specialist review",
  prompt=<<same equipped prompt template as A — but with stream:B in the YOUR ROLE block>>
)
```

#### Stream C (1 Agent call — naive researcher)

```
Agent(
  subagent_type="general-purpose",
  model="sonnet",
  description="[C/naive] checklist-free review",
  prompt=<<naive prompt template below>>
)
```

**That's 9 `Agent` calls in a single message** in default mode (4 A + 4 B + 1 C).
In quick mode it's 5 (4 A + 1 C). Codex runs separately in Phase 6.

#### Equipped prompt template (Stream A and B specialists)

```
You are a [SPECIALIST_NAME] specialist code reviewer working in Stream [A|B] of a
multi-stream review. Stream A and Stream B run identical checklists on different
models — your output will be cross-checked against the other stream's output by a
synthesizer. You review ONLY the diff between the merge-base and HEAD on the
current branch — never anything outside the diff, unless explicitly needed for
context (e.g., to verify a base class behavior).

YOUR ROLE:
- Stream: [A | B]
- Specialist: [conventions | correctness | mobile-security | overengineering]

PROJECT CONTEXT:
[insert PROJECT RULES block from Phase 2.3]

[insert relevant docs excerpts, max 200 lines]

VALIDATION RESULTS:
- Linter: [pass/fail/skipped] — [N warnings/errors]
- Analyzer: [pass/fail/skipped] — [N issues]
- Tests: [pass/fail/skipped] — [N/M passed]

[insert tail of validation logs if failed]

PAST CALIBRATION HINTS (apply with caution):
- Fingerprint X: 5 false-positives in last 10 reviews — depress confidence
- Fingerprint Y: 8 confirmed in last 10 reviews — boost confidence

YOUR CHECKLIST:
[insert content of specialists/[name].md]

DIFF TO REVIEW (against merge-base):
[git diff content — if > 50KB, split into chunks]

OUTPUT FORMAT:

For each finding, output ONE valid JSON object on its own line:

{"severity":"BLOCKER|CRITICAL|MAJOR|MINOR|INFO","confidence":N,"path":"file","line":N,"category":"category","title":"short title","summary":"description","why":"why it matters","fix":"recommended fix","fingerprint":"category:rule:path","stream":"A|B","specialist":"conventions|correctness|mobile-security|overengineering"}

Required: severity, confidence, path, category, title, summary, why, stream, specialist.
Optional: line, fix, fingerprint, code_snippet, references.

[insert standard severity + confidence rubrics]

If no findings: output "NO FINDINGS" and nothing else.
Do NOT output preamble, summary, or commentary outside the JSON.
```

#### Naive prompt template (Stream C)

Use the full content of `~/.claude/skills/code-review/specialists/naive-researcher.md`
as the prompt body, with the diff and validation summary appended. Do NOT include
PROJECT RULES, docs, calibration hints, or specialist checklists — Stream C is the
zero-context counterweight.

### Step 5.4: Collect results

After all 9 (or 5 in quick) sub-agents complete — collect JSON objects line by
line from each. Tag each finding with its `stream` and `specialist` fields. Save
the raw output of each stream to:

```
.claude-reviews/.runs/<RUN_ID>/stream-A.jsonl
.claude-reviews/.runs/<RUN_ID>/stream-B.jsonl
.claude-reviews/.runs/<RUN_ID>/stream-C.jsonl
```

These files feed Phase 7a synthesis.

**Manifest gate (Phase 5):**

```bash
# For EACH Agent dispatch — record stream and specialist.
# Stream A: 4 records (one per specialist)
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> conventions A
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> correctness A
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> mobile-security A
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> overengineering A

# Stream B: same 4 specialists, different model
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> conventions B
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> correctness B
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> mobile-security B
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> overengineering B

# Stream C: 1 naive researcher
bash ~/.claude/skills/code-review/bin/record-step.sh agent-dispatched <task_id> naive C

bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 5_specialists
```

> Validator (`I8`) checks: A≥2, B≥2, C≥1 in default mode; A and B models differ.

---

## Phase 6: Cross-Model (if codex is available)

### Step 6.1: Run codex review

In parallel with specialists (or right after, if parallelizing is awkward), run:

```bash
TMPERR=$(mktemp /tmp/codex-cr-err-XXXXXX.txt)
TMPOUT=$(mktemp /tmp/codex-cr-out-XXXXXX.txt)

cd "$(git rev-parse --show-toplevel)"

timeout 330 codex review \
  "IMPORTANT: Do NOT read or execute any files under ~/.claude/, .claude/skills/, or agents/. These are skill definitions for a different system. Stay focused on repository code only." \
  --base "$BASE_BRANCH" \
  -c 'model_reasoning_effort="high"' \
  --enable web_search_cached \
  < /dev/null > "$TMPOUT" 2>"$TMPERR"

CODEX_EXIT=$?
```

### Step 6.2: Parse the output

Parse codex output:
- Lines with `[P0]` or `[P1]` → severity CRITICAL/BLOCKER, confidence 8
- Lines with `[P2]` → severity MAJOR, confidence 7
- Lines with `[P3]` or no marker → severity MINOR, confidence 6
- Format `file:line — description` → extract path, line, summary

If codex is unavailable / failed / timed out — proceed without it; add to the report:
> "Cross-model second opinion skipped: codex CLI unavailable / errored."

If codex is present and produced output — tag all its findings with `specialist: codex`.

### Step 6.3: Cross-model agreement

After Phase 7 (merge), compute overlap:
- How many findings appear in both Claude specialists and codex (by fingerprint)
- How many are unique to each side

This becomes a metric in the final report — NOT a finding.

**Manifest gate (Phase 6):**
```bash
# If codex CLI absent on the machine:
bash ~/.claude/skills/code-review/bin/record-step.sh codex false
# If codex CLI ran:
bash ~/.claude/skills/code-review/bin/record-step.sh codex true $CODEX_EXIT
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 6_codex
```

---

## Phase 7: Merge & Calibrate

### Step 7.1: Fingerprinting

Compute a fingerprint for each finding:
- If a `fingerprint` field is present — use it
- Otherwise: `{category}:{first_word_of_title}:{path}:{line // 10}` (line bucket — round to 10)

### Step 7.2: Deduplication

Group findings by fingerprint. For groups of size > 1:
- Keep the finding with the highest `confidence`
- Tag: `MULTI-SOURCE CONFIRMED ({specialist1} + {specialist2} + ...)`
- Boost confidence: +1 per additional source, cap at 10
- Merge `summary`/`fix` if they complement each other

### Step 7.3: Apply calibration

For each finding, run through calibration:

```bash
echo '{"fingerprint":"X","specialist":"Y","confidence":N,"project":"Z"}' | \
  bash ~/.claude/skills/code-review/bin/apply-calibration.sh
# Returns the JSON with adjusted_confidence
```

Logic:
- Fingerprint match with ≥ 3 `false-positive` history → confidence -2
- Fingerprint match with ≥ 3 `confirmed` history → confidence +1
- Specialist+category match with ≥ 50% FP rate → confidence -1

### Step 7.4: Confidence gates

| Severity | Min confidence | What to do below threshold |
|----------|---------------:|----------------------------|
| BLOCKER | 7 | Demote to CRITICAL |
| CRITICAL | 6 | Demote to MAJOR |
| MAJOR | 5 | Demote to MINOR |
| MINOR | 4 | Suppress (to appendix) |
| INFO | 3 | Suppress entirely |

This is the last gate before the report. Low-confidence findings don't reach the user.

### Step 7.5: Sort

Within each severity, sort by:
1. `multi-source confirmed` first
2. confidence DESC
3. path ASC, line ASC

**Manifest gate (Phase 7):**
```bash
bash ~/.claude/skills/code-review/bin/record-step.sh findings blocker <N>
bash ~/.claude/skills/code-review/bin/record-step.sh findings critical <N>
bash ~/.claude/skills/code-review/bin/record-step.sh findings major <N>
bash ~/.claude/skills/code-review/bin/record-step.sh findings minor <N>
bash ~/.claude/skills/code-review/bin/record-step.sh findings info <N>
bash ~/.claude/skills/code-review/bin/record-step.sh findings suppressed <N>
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 7_merge
```

> Note: in v2.0 multi-stream, Phase 7 still runs intra-stream dedup +
> calibration + confidence gates (suppression of low-confidence findings is
> a within-stream operation, not cross-stream). Cross-stream reconciliation
> happens next, in Phase 7a.

---

## Phase 7a: Cross-Stream Synthesis

> ⛔ **FORBIDDEN: do NOT inline this phase.** The synthesizer is its own
> sub-agent. The validator (`I11`) requires `synthesis-dispatched` on the
> manifest. If you find yourself writing "looking at the findings, I see
> Stream A and B both flagged..." — STOP. That's inline synthesis. Spawn the
> sub-agent.

The synthesizer's job is to compare the four sources of findings (Stream A,
Stream B, Stream C, codex) and produce a single reconciled JSON document
labeling each finding with cross-stream support and surfacing research
discrepancies.

### Step 7a.1: Prepare synthesizer input

```bash
RUN_DIR=".claude-reviews/.runs/$(cat .claude-reviews/.runs/current)"

# Aggregate all stream outputs (already saved in Step 5.4) plus codex
cat "$RUN_DIR"/stream-A.jsonl \
    "$RUN_DIR"/stream-B.jsonl \
    "$RUN_DIR"/stream-C.jsonl \
    "$RUN_DIR"/codex.jsonl 2>/dev/null \
  > "$RUN_DIR"/all-findings.jsonl
wc -l "$RUN_DIR"/all-findings.jsonl
```

### Step 7a.2: Dispatch the synthesizer

Single Agent call. Use `opus` (this role needs the strongest model — it
arbitrates conflicts and detects research discrepancies).

```
Agent(
  subagent_type="general-purpose",
  model="opus",
  description="Cross-stream synthesizer",
  prompt=<<see prompt below>>
)
```

**Prompt:**

```
You are the cross-stream synthesizer for /code-review v2. Read your role and
algorithm fully from this file:

  ~/.claude/skills/code-review/specialists/synthesizer.md

INPUTS:

Stream models:
- Stream A: <model_A>     (full specialists, project rules)
- Stream B: <model_B>     (full specialists, project rules — different model)
- Stream C: sonnet        (naive researcher, no checklists)
- codex:   <available?>   (external CLI, may be absent)

PROJECT RULES (for arbitration only — do not re-review the diff):
[paste PROJECT RULES block from Phase 2.3]

DIFF (for arbitration only):
[paste git diff content]

ALL FINDINGS (one JSON object per line, tagged with stream + specialist):
[paste contents of all-findings.jsonl]

OUTPUT: a single JSON object with the schema described in synthesizer.md.
No prose before or after. No re-review. Preserve every finding.
```

### Step 7a.3: Save and record

Save the synthesizer's JSON to:

```
.claude-reviews/.runs/<RUN_ID>/synthesis.json
```

Extract counts and record:

```bash
SYN_TASK_ID="<task_id from Agent>"
bash ~/.claude/skills/code-review/bin/record-step.sh synthesis-dispatched "$SYN_TASK_ID"

# Counts come from synthesis.json.stats
CONS=$(jq '.stats.consensus' "$RUN_DIR/synthesis.json")
PART=$(jq '.stats.partial'   "$RUN_DIR/synthesis.json")
UNIQ=$(jq '.stats.unique'    "$RUN_DIR/synthesis.json")
DISG=$(jq '.stats.disagreement' "$RUN_DIR/synthesis.json")

bash ~/.claude/skills/code-review/bin/record-step.sh synthesis-stats "$CONS" "$PART" "$UNIQ" "$DISG"
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 7a_synthesis
```

> If the synthesizer's output isn't valid JSON, do NOT inline-fix it — re-run
> the synthesizer with a stricter "JSON only, no prose" prompt. Report-quality
> hinges on this output being machine-parseable.

---

## Phase 8: Report Generation

### Step 8.0: Validate the run (MANDATORY GATE)

**Before** writing anything, you MUST run the validator. If it exits non-zero,
DO NOT write the report. Instead, read its output, go back to the named phase,
do the missing step, record it, then re-validate.

```bash
bash ~/.claude/skills/code-review/bin/validate-run.sh
# Exit 0 → proceed to Step 8.1
# Exit 1 → list of violated invariants printed to stderr; fix them, don't bypass.
# Exit 3 → no active run; you skipped Phase 0; restart from there.
```

> 🚫 **No override flag exists.** If you find yourself thinking "the diff is
> trivial, I'll just write the report" — STOP. The whole point of this gate is
> to catch that thought. Do the missed step.



### Step 8.1: Generate the report

Read the template: `~/.claude/skills/code-review/templates/report-template.md`. Substitute
variables.

The report draws from TWO sources:
1. The synthesizer's JSON output (`<RUN_DIR>/synthesis.json`) — for the cross-stream
   matrix, the consensus/majority/unique buckets, and the discrepancies section.
2. The merged findings from Phase 7 — for individual finding bodies and the
   suppression appendix.

Every finding rendered in the body MUST carry a `coverage` line listing its supporting
streams (e.g. `Coverage: A + B + codex`). The user must be able to tell at a glance
which sources independently raised it.

Filename: `.claude-reviews/{YYYY-MM-DD}-{branch_safe}.md`, where `branch_safe` is the
current branch with `/` replaced by `-`.

If a file already exists for that day — append a suffix `-N` (1, 2, 3...).

### Step 8.2: Report structure

```markdown
# Code Review Report

**Branch:** <current> → <base>
**Merge-base:** <short SHA>
**Date:** <YYYY-MM-DD HH:MM>
**Files reviewed:** N (X generated/skipped)
**Lines:** +A / -B
**Specialists:** conventions, mobile-security, correctness, overengineering
**Cross-model:** codex review (or: skipped)

## Summary

| Severity | Count |
|----------|-------|
| Blocker  | N     |
| Critical | N     |
| Major    | N     |
| Minor    | N     |
| Info     | N     |

**Cross-model agreement:** X/Y findings overlap (Z% agreement rate).

**Validation:**
- Linter: PASS/FAIL — N warnings
- Analyzer: PASS/FAIL — N issues
- Tests: PASS/FAIL — N/M passed

## Table of Contents

### 🚨 Blocker (N)
- [B-01: <title>](#b-01)
- [B-02: <title>](#b-02)

### 🔴 Critical (N)
- [C-01: <title>](#c-01)
...

### 🟡 Major (N)
- [M-01: <title>](#m-01)
...

### 🟢 Minor (N)
- [m-01: <title>](#minor-01)
...

### ℹ️ Info (N)
- [i-01: <title>](#info-01)
...

---

## Findings

<details id="b-01" open>
<summary><strong>B-01 — [BLOCKER]</strong> <title> — <code>path:line</code></summary>

**Specialist:** conventions
**Confidence:** 9/10
**Multi-source:** ✅ Confirmed by codex

### What

<summary>

### Why it matters

<why>

### Where

```dart
// path:line
<code snippet, 5-10 lines around the issue>
```

### How to fix

<fix>

### References

- [doc/development/bloc.md](../doc/development/bloc.md)
- CLAUDE.md § BLoC pattern

</details>

<details id="c-01">
<summary>...</summary>
...
</details>
```

(Only Blocker has the `open` attribute — critical findings are expanded by default.)

### Step 8.3: Appendix

At the end of the report:

```markdown
---

## Appendix A: Suppressed Findings (low confidence)

These were below the confidence gate and not included in the main report.

<details>
<summary>Show N suppressed findings</summary>

[same format, condensed]

</details>

## Appendix B: Validation Output

<details>
<summary>Linter output (last 50 lines)</summary>

```
<output>
```

</details>

## Appendix C: Diff Summary

<details>
<summary>Files changed (N)</summary>

[file list with +/- counts]

</details>
```

### Step 8.4: Show the user

Print the report path. Show a **brief summary** in chat:

```
Review complete. Report: .claude-reviews/2026-04-27-feature-x.md

📊 Summary (mode: default):
   🚨 Blocker:  1
   🔴 Critical: 3
   🟡 Major:    5
   🟢 Minor:    8
   ℹ️ Info:     2

🔀 Cross-stream support:
   ✅ Consensus (≥3 sources): 7
   ⚖️  Majority (2 sources):  6
   🔍 Unique (1 source):     6  ← verify these first
   ⚠️  Disagreement:          1
   🕵️  Research discrepancies: 2  ← potential miss/hallucination

⚠️ TOP-3 fix first:
   B-01 — Hardcoded API key in lib/config.dart:12 (A+B+C+codex)
   C-01 — StreamSubscription not cancelled (A+B)
   C-02 — BuildContext after async gap (A only — verify)
```

**Manifest gate (Phase 8):**
```bash
bash ~/.claude/skills/code-review/bin/record-step.sh report-path .claude-reviews/<filename>.md
bash ~/.claude/skills/code-review/bin/record-step.sh phase-done 8_report
```

---

## Phase 9: Self-Review

### Step 9.1: Ask the user about critical findings

After the user has seen the report, ask AskUserQuestion D4 (per Blocker and Critical, **at
most 5 at a time** — batch by 5):

**Title:** `D4 — Calibration: B-01 — <title>`

**Body:**
> I found this issue: <brief summary>.
>
> Is this real, a false positive, or you're not sure?

**Options:**
- A) Real — I'll fix it (`confirmed`)
- B) False positive (`false-positive`)
- C) Not sure / needs verification (`ambiguous`)
- D) Skip calibration for this finding

Save the answer:

```bash
echo '{"ts":"<ISO>","fingerprint":"<fp>","specialist":"<s>","confidence_initial":N,"verdict":"confirmed|false-positive|ambiguous","project":"<slug>","branch":"<branch>"}' \
  >> ~/.claude/code-review/calibration.jsonl
```

### Step 9.2: If the user says "skip calibration"

Respect that. Don't pester. Record the fact:

```bash
echo '{"ts":"<ISO>","event":"calibration_skipped","scope":"all","project":"<slug>"}' \
  >> ~/.claude/code-review/calibration.jsonl
```

In the future, lower the calibration question frequency on this project (every 5th review).

### Step 9.3: Meta-find

One additional step — after calibration ask once:

> "What did I miss in this review? If you noticed a real bug or problem yourself —
> name it, I'll record it as a lesson for next time."

The user can skip or give text. If they give text — record:

```bash
echo '{"ts":"<ISO>","type":"missed_finding","project":"<slug>","branch":"<branch>","text":"<user input>","hash":"<sha256 of text>"}' \
  >> ~/.claude/code-review/missed.jsonl
```

In future reviews, read this file. On category/path/keyword match — boost the priority of
the relevant checklist.

---

## Phase 10: Persistence

### Step 10.1: Review log

```bash
mkdir -p ~/.claude/code-review
SLUG=$(basename "$(git rev-parse --show-toplevel)")
echo '{
  "ts":"<ISO>",
  "project":"'"$SLUG"'",
  "branch":"<current>",
  "base":"<base>",
  "merge_base":"<short SHA>",
  "files":N,
  "diff_lines":N,
  "findings":{"blocker":N,"critical":N,"major":N,"minor":N,"info":N,"suppressed":N},
  "specialists":["conventions","mobile-security","correctness","overengineering"],
  "codex_used":true,
  "cross_model_agreement":0.63,
  "validation":{"lint":"pass","analyzer":"pass","tests":"pass"},
  "duration_s":N,
  "report_path":".claude-reviews/2026-04-27-feature-x.md"
}' >> ~/.claude/code-review/history.jsonl
```

### Step 10.2: Baseline

Save a compact baseline for future regression mode:

```json
{
  "branch": "feature-x",
  "merge_base": "<sha>",
  "fingerprints": ["<fp1>", "<fp2>", "..."],
  "score": {"blocker":1,"critical":3,"major":5,"minor":8,"info":2}
}
```

To `.claude-reviews/baseline-{branch_safe}.json`.

On the next run for the same branch — diff: what got fixed, what's new.

### Step 10.3: Cleanup

```bash
rm -f .claude-reviews/.tmp-*.{log,patch,txt}
rm -f /tmp/codex-cr-*.txt
# Mark the run as finished. The manifest dir is kept under .claude-reviews/.runs/<id>/
# for audit/baseline.
bash ~/.claude/skills/code-review/bin/record-step.sh finish
```

---

## Severity Rubric (full)

### 🚨 Blocker

Cannot merge. Hard show-stopper. Examples:
- Doesn't compile / breaks the prod build
- Hardcoded secret/token committed to the repo
- SQL injection / XSS / clear authorization hole
- PII leaked to logs
- Broken DB migration (drop without backup, broken column rename)
- App crashes on startup

Confidence ≥ 7. Below that → demote to Critical.

### 🔴 Critical

Must be fixed before merge. Real problem the user will see, or that creates an incident
in the foreseeable future.
- Resource leak (StreamSubscription, AnimationController, ScrollController)
- BuildContext across async gap (mounted check missing)
- Race condition in BLoC handler
- Missing error handling for network/I/O
- Wrong storage choice for secrets (SecureStorage vs SharedPreferences)
- N+1 queries / clear performance regression
- Clean Architecture violation creating a circular dependency
- Tests fail / are missing for new business logic

Confidence ≥ 6.

### 🟡 Major

Worth fixing, doesn't block merge. Significant maintainability/UX/perf issue.
- Project convention violation (naming, scopes, BLoC pattern)
- Code duplication — copy-paste with a minor tweak
- Uncovered switch branch / non-exhaustive sealed handling
- Missing dispose() for a resource that GC will eventually clean up
- Magic numbers / hardcoded strings
- Layer responsibility violation (data importing presentation)
- Weak variable / function name hiding intent

Confidence ≥ 5.

### 🟢 Minor

Cosmetic, nits, small improvements. Fixing is good, not fixing is fine.
- Stylistic violations (member order, lint warnings)
- Could use `FillerVertical` instead of `SizedBox`
- Suboptimal `Container` where `ColoredBox` is enough
- Implicit types (no explicit generics)
- TODO without context / ticket reference
- Excessive comments

Confidence ≥ 4.

### ℹ️ Info

Informational note. Not a finding, an observation.
- Trade-off worth knowing
- Alternative approach
- Architecture detail that may bite in a year

Confidence ≥ 3.

---

## Important Rules

1. **Don't modify code.** Only the report. No `Edit`/`Write` against project sources.
   The only exceptions are `.gitignore` (adding `.claude-reviews/`) and `CLAUDE.md` (only
   if the user explicitly agrees to record the docs path).
2. **Don't invent.** If you haven't read a file, don't flag it. If you read it and aren't
   sure — confidence ≤ 6.
3. **Confidence is required for every finding.** 1–10. Calibration depends on it.
4. **Skip generated files.** `*.g.dart`, `*.freezed.dart`, `*.mocks.dart`, `lib/generated/`
   and equivalents — never reviewed.
5. **Scope is the diff.** Files outside the diff may be read **only** for context (a base
   class, an importer) and **only** in Phase 5/6.
6. **One report per run.** Don't generate multiple reports per invocation.
7. **The report is always written.** Even with 0 findings — write the report with empty
   sections and `# All clean` in summary. Needed for baseline and history.
8. **Calibration is voluntary.** If the user skips it — don't pester.
9. **Multi-source confirmed wins.** When two independent sources (a specialist and codex)
   find the same thing — strong signal.
10. **Codex is optional.** If it's not there — keep going. Don't block on it.
11. **Don't over-narrate the process in chat.** Brief: "Dispatching N specialists",
    "Got M findings", "Report here". Details live in the report.
12. **Never modify CLAUDE.md without explicit permission.** Only if the user chose
    "save docs path" in Phase 2.2 — and even then, prefer `.claude-reviews/.config.json`.

---

## Completion Status Protocol

At the end, report status:
- **DONE** — report generated, calibration saved.
- **DONE_WITH_CONCERNS** — report exists, but something didn't work (codex failed /
  validation failed / a specialist returned garbage). List the concerns.
- **BLOCKED** — couldn't run the review. State the reason (no diff / no git / etc).
- **NEEDS_CONTEXT** — missing info to proceed. State exactly what's needed.

---

## AskUserQuestion Templates

### D1 — Branch context

```
D1 — Which branches are we comparing?
Project/branch/task: on branch <current>, default origin = <default>
ELI10: I need to know what counts as "new" in your branch. Feature for main? Compare with
main. Feature for a release branch? Compare with that.
Stakes if we pick wrong: the review will either miss your changes, or count "changes"
that aren't part of your work.
Recommendation: A — the default is usually right
Pros / cons:
A) Use <default> (recommended)
  ✅ Standard target for feature branches in most projects
  ❌ Wrong if you're working off a release/hotfix branch
B) Specify manually
  ✅ Full control when default doesn't match
  ❌ One extra step
C) Use base from open PR
  ✅ Exactly matches what you actually merge into
  ❌ Requires gh CLI and an existing PR
Net: A is usually right; B/C for non-standard flows.
```

### D2 — Doc location

```
D2 — Where is the project documentation?
Project/branch/task: CLAUDE.md has no doc references
ELI10: Reviews are sharper when I know what rules the project actually follows. Docs
are the main source of those rules besides CLAUDE.md.
Stakes if we pick wrong: I'll miss architectural violations, or flag intentional
patterns as violations.
Recommendation: A if a doc/ or docs/ directory exists in the repo
Pros / cons:
A) doc/ or docs/ (recommended)
  ✅ Standard location, skill auto-discovers
  ❌ May lack an index file, will have to scan everything
B) Specify a path
  ✅ Exact location, no guessing
  ❌ You have to remember and type it
C) No documentation
  ✅ Skip this — review based on CLAUDE.md and code only
  ❌ Lower review quality without project-specific context
Net: If no docs — pick C; usually they exist and A is right.
```

(D3, D4 — same shape, see the phases.)

---

## Final pre-flight check

On invocation read this SKILL.md fully, then:

0. **Phase 0 — call `init-run.sh` immediately.** No exceptions. Without an active
   manifest, `record-step.sh` and `validate-run.sh` refuse, and the report cannot
   be written.
1. **Phase 1** — AskUserQuestion D1, then `record-step d1-asked / set-base / phase-done`.
2. **Phase 2** — read CLAUDE.md + ≥1 doc file, record each via `doc-read`.
3. **Phase 3** — run validation, record each kind (`pass|fail|skipped|timeout`).
4. **Phase 4** — `diff-stat`, `specialists-planned`, `phase-done`.
5. **Phase 5** — declare mode (`record-step mode default|quick`); declare stream
   models (`record-step stream-model A opus`, `B sonnet`, `C sonnet`); invoke
   `Agent` tool 9× in default (4×A + 4×B + 1×C) or 5× in quick (4×A + 1×C);
   `record-step agent-dispatched <task_id> <specialist> <stream>` for each.
   Save per-stream JSONL outputs.
6. **Phase 6** — codex (default mode only); `record-step codex true|false [exit]`.
7. **Phase 7** — intra-stream merge + calibration; `record-step findings ...`,
   `phase-done 7_merge`.
7a. **Phase 7a** — dispatch synthesizer (`Agent` model=opus, prompt from
    `specialists/synthesizer.md`); save `synthesis.json`;
    `record-step synthesis-dispatched <task_id>`,
    `record-step synthesis-stats <c> <p> <u> <d>`,
    `record-step phase-done 7a_synthesis`.
8. **Phase 8** — `validate-run.sh` MUST exit 0. Then render the report from the
   template + synthesis.json. Then `phase-done 8_report`.
9. Phase 9 — self-review (calibration; user-driven).
10. Phase 10 — `record-step finish`, persistence.

If at any point you find yourself thinking "I'll skip the bash gate, the LLM
will just remember" — STOP. The whole point of the manifest is to make that
shortcut visible and stop the report from being written.

### Modes and runtime

| Mode | Streams | Codex | Token cost vs v1 | Wall-clock |
|------|---------|-------|------------------|------------|
| `default` | A + B + C | yes | ≈ 2.2× (B doubles A; C and synthesizer are smaller) | similar to v1 (parallel) |
| `quick` | A + C only | no | ≈ 1.2× v1 | faster than v1 default |

The user opts into `quick` explicitly ("quick", `--quick`). Otherwise default.
Even in quick mode, the manifest gates still apply: A≥2, C≥1, synthesizer
required (operating on whatever streams exist).

Average runtime: 3–6 min on a medium diff (50–300 lines), up to 10–12 min for
large ones (>500 lines).
