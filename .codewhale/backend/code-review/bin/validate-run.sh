#!/usr/bin/env bash
# validate-run.sh — verify the active run's manifest is complete enough to
# generate a report. Exits non-zero with a list of unmet invariants if not.
#
# Usage:
#   bash validate-run.sh                # validate for report generation
#   bash validate-run.sh --pre-report   # same, default
#   bash validate-run.sh --json         # emit JSON instead of human text
#
# Exit codes:
#   0 — all invariants met
#   1 — one or more invariants violated (details on stdout)
#   3 — no active run / manifest missing
#
# Invariants for --pre-report (default):
#   I1  Phase 0 (preflight) done
#   I2  base + merge_base recorded
#   I3  D1 asked (or method=default explicitly recorded)
#   I4  CLAUDE.md read (if CLAUDE.md exists in repo root)
#   I5  Docs read: at least 1 file from doc/ or docs/ tree (if such dir exists
#       AND has any *.md files)
#   I6  Validation attempted: at least one of lint/analyzer/test recorded
#       with status != null (skipped is acceptable)
#   I7  Diff scoping done: files_reviewed > 0
#   I8  Multi-stream specialist dispatch:
#         mode=default → Stream A ≥2 dispatched AND Stream B ≥2 dispatched
#                        AND Stream C ≥1 dispatched (naive researcher).
#                        A and B MUST use different models.
#         mode=quick   → Stream A ≥2 dispatched AND Stream C ≥1 dispatched.
#   I9  Codex attempted (mode=default only; quick mode skips codex).
#   I10 Phase 7 (merge) done
#   I11 Phase 7a (synthesis) done with synthesis-dispatched recorded
#       (cross-stream reconciliation must go through a sub-agent, not be inlined).

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

CURRENT_FILE=".claude-reviews/.runs/current"

if [ ! -f "$CURRENT_FILE" ]; then
  echo "FAIL: no active run. Did you call init-run.sh?" >&2
  exit 3
fi

RUN_ID="$(cat "$CURRENT_FILE")"
MANIFEST=".claude-reviews/.runs/$RUN_ID/manifest.json"

if [ ! -f "$MANIFEST" ]; then
  echo "FAIL: manifest missing at $MANIFEST" >&2
  exit 3
fi

MODE="pre-report"
EMIT_JSON=0
for arg in "$@"; do
  case "$arg" in
    --pre-report) MODE="pre-report" ;;
    --json) EMIT_JSON=1 ;;
    *) echo "Unknown flag: $arg" >&2; exit 2 ;;
  esac
done

# Read manifest fields via jq
get() { jq -r "$1" "$MANIFEST"; }

FAILS=()

check() {
  local id="$1" desc="$2" cond="$3"
  if ! eval "$cond"; then
    FAILS+=("$id — $desc")
  fi
}

# I1 — Phase 0 done
check I1 "Phase 0 preflight not marked done" '[ "$(get .phases.\"0_preflight\".done)" = "true" ]'

# I2 — base + merge_base
check I2 "base or merge_base not recorded (run record-step set-base ...)" \
  '[ "$(get .base)" != "null" ] && [ "$(get .merge_base)" != "null" ]'

# I3 — D1 asked
check I3 "D1 not asked (run record-step d1-asked <method>)" \
  '[ "$(get .phases.\"1_branch_context\".d1_asked)" = "true" ]'

# I4 — CLAUDE.md
if [ -f CLAUDE.md ]; then
  check I4 "CLAUDE.md exists in repo but not recorded as read" \
    '[ "$(get .phases.\"2_doc_gate\".claude_md_read)" = "true" ]'
fi

# I5 — docs read (only if there's a doc/ or docs/ dir with markdown files)
DOC_DIR=""
for d in doc docs documentation; do
  if [ -d "$d" ] && [ "$(find "$d" -name '*.md' -type f 2>/dev/null | head -1)" ]; then
    DOC_DIR="$d"
    break
  fi
done

if [ -n "$DOC_DIR" ]; then
  DOCS_READ_COUNT=$(get '.phases."2_doc_gate".docs_read | length')
  if [ "$DOCS_READ_COUNT" -lt 1 ]; then
    FAILS+=("I5 — Docs directory '$DOC_DIR' exists but no doc files were recorded as read")
  fi
fi

# I6 — at least one validation step recorded
LINT_STATUS=$(get '.phases."3_validation".lint.status // "null"')
ANALYZER_STATUS=$(get '.phases."3_validation".analyzer.status // "null"')
TEST_STATUS=$(get '.phases."3_validation".test.status // "null"')
if [ "$LINT_STATUS" = "null" ] && [ "$ANALYZER_STATUS" = "null" ] && [ "$TEST_STATUS" = "null" ]; then
  FAILS+=("I6 — No validation step recorded. Run at least lint/analyzer/test, even if status=skipped")
fi

# I7 — files reviewed
FILES_REVIEWED=$(get '.phases."4_diff_scoping".files_reviewed')
if [ "$FILES_REVIEWED" = "null" ] || [ "$FILES_REVIEWED" -lt 1 ]; then
  FAILS+=("I7 — files_reviewed is 0 or null. Run record-step diff-stat <total> <reviewed>")
fi

# I8 — multi-stream specialist dispatch
MODE=$(get '.mode // "default"')
A_COUNT=$(get '.phases."5_specialists".streams.A.dispatched | length')
B_COUNT=$(get '.phases."5_specialists".streams.B.dispatched | length')
C_COUNT=$(get '.phases."5_specialists".streams.C.dispatched | length')
A_MODEL=$(get '.phases."5_specialists".streams.A.model // "null"')
B_MODEL=$(get '.phases."5_specialists".streams.B.model // "null"')

if [ "$MODE" = "quick" ]; then
  if [ "$A_COUNT" -lt 2 ]; then
    FAILS+=("I8 — quick mode: Stream A has $A_COUNT specialist(s), required ≥2. Use Agent tool, then record-step agent-dispatched <task_id> <specialist> A")
  fi
  if [ "$C_COUNT" -lt 1 ]; then
    FAILS+=("I8 — quick mode: Stream C (naive researcher) not dispatched. Run an Agent for the naive researcher, then record-step agent-dispatched <task_id> naive C")
  fi
else
  # default mode
  if [ "$A_COUNT" -lt 2 ]; then
    FAILS+=("I8 — Stream A has $A_COUNT specialist(s), required ≥2. Use Agent tool, then record-step agent-dispatched <task_id> <specialist> A")
  fi
  if [ "$B_COUNT" -lt 2 ]; then
    FAILS+=("I8 — Stream B has $B_COUNT specialist(s), required ≥2. Stream B is the independent second-opinion review.")
  fi
  if [ "$C_COUNT" -lt 1 ]; then
    FAILS+=("I8 — Stream C (naive researcher) not dispatched. The naive researcher gets the diff with no checklists or project rules.")
  fi
  if [ "$A_MODEL" = "null" ] || [ "$B_MODEL" = "null" ]; then
    FAILS+=("I8 — Stream A and B must declare their model via record-step stream-model A|B <model>. Required for traceability.")
  elif [ "$A_MODEL" = "$B_MODEL" ]; then
    FAILS+=("I8 — Stream A and Stream B share the same model ('$A_MODEL'). They must use different models for true independent perspectives.")
  fi
fi

# I9 — codex attempted (only required in default mode)
if [ "$MODE" != "quick" ]; then
  CODEX_ATTEMPTED=$(get '.phases."6_codex".attempted')
  if [ "$CODEX_ATTEMPTED" != "true" ]; then
    FAILS+=("I9 — Codex not attempted. Run record-step codex true|false [exit_code]")
  fi
fi

# I10 — phase 7 done
check I10 "Phase 7 merge & calibrate not marked done" \
  '[ "$(get .phases.\"7_merge\".done)" = "true" ]'

# I11 — phase 7a synthesis done
SYN_DONE=$(get '.phases."7a_synthesis".done')
SYN_DISPATCHED=$(get '.phases."7a_synthesis".agent_dispatched')
if [ "$SYN_DONE" != "true" ]; then
  FAILS+=("I11 — Phase 7a synthesis not marked done. Cross-stream reconciliation is mandatory.")
fi
if [ "$SYN_DISPATCHED" != "true" ]; then
  FAILS+=("I11 — Synthesis sub-agent was not dispatched. Synthesis MUST go through Agent tool (not inline). Run record-step synthesis-dispatched <task_id>.")
fi

# --- Output ---
if [ "$EMIT_JSON" = 1 ]; then
  if [ ${#FAILS[@]} -eq 0 ]; then
    echo '{"ok":true,"violations":[]}'
  else
    printf '{"ok":false,"violations":['
    first=1
    for f in "${FAILS[@]}"; do
      [ $first -eq 1 ] && first=0 || printf ','
      printf '"%s"' "$(echo "$f" | sed 's/"/\\"/g')"
    done
    printf ']}\n'
  fi
else
  if [ ${#FAILS[@]} -eq 0 ]; then
    echo "validate-run: OK ($MODE) — manifest at $MANIFEST"
  else
    echo "validate-run: FAIL ($MODE) — ${#FAILS[@]} invariant(s) violated:" >&2
    for f in "${FAILS[@]}"; do
      echo "  ✗ $f" >&2
    done
    echo "" >&2
    echo "Manifest: $MANIFEST" >&2
    echo "Fix the violations above, then re-run validate-run.sh." >&2
  fi
fi

[ ${#FAILS[@]} -eq 0 ]
