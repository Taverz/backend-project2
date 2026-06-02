#!/usr/bin/env bash
# record-step.sh — atomic update to the active run's manifest.json.
# All mutations to the run state must go through this script so validate-run.sh
# can trust the manifest.
#
# Subcommands:
#   phase-done <phase>                       Mark phase as done.
#                                            <phase> ∈ {0_preflight, 1_branch_context, ...}
#
#   d1-asked <method>                        Record that D1 was asked. <method> ∈ {ask, gh, default, manual}.
#
#   claude-md-read                           Record CLAUDE.md was read.
#   doc-read <path>                          Append a doc path to docs_read[].
#   rules-extracted                          Record PROJECT RULES block was produced.
#
#   set-base <branch> <merge_base_sha>       Record base branch + merge-base SHA.
#
#   validation <kind> <status> [duration]    <kind> ∈ {lint, analyzer, test};
#                                            <status> ∈ {pass, fail, skipped, timeout}.
#
#   diff-stat <files_total> <files_reviewed>
#   specialists-planned <name1,name2,...>
#
#   stream-model <stream> <model>            Record which model is used for the stream.
#                                            <stream> ∈ {A, B, C}; <model> any string (e.g. opus, sonnet).
#
#   agent-dispatched <task_id> <specialist> <stream>
#                                            Record an Agent invocation for a specialist in a stream.
#                                            <specialist> ∈ {conventions, mobile-security, correctness,
#                                                            overengineering, naive}.
#                                            <stream>     ∈ {A, B, C}.
#
#   codex <available> [exit]                 <available> ∈ {true, false}; exit code if attempted.
#
#   mode <mode>                              Record run mode. <mode> ∈ {default, quick}.
#
#   synthesis-dispatched <task_id>           Record that the synthesis sub-agent was dispatched.
#   synthesis-stats <consensus> <partial> <unique> <disagreement>
#                                            Record cross-stream synthesis counts.
#
#   findings <severity> <count>              <severity> ∈ {blocker,critical,major,minor,info,suppressed}.
#
#   report-path <path>                       Record final report path.
#
#   warn <text>                              Append to warnings[].
#   error <text>                             Append to errors[].
#
#   finish                                   Set finished_at to now.
#
#   show                                     Print manifest.json to stdout.
#
# Exit codes:
#   0 — ok
#   2 — usage error
#   3 — no active run (init-run.sh not called yet)
#   4 — invalid argument

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

CURRENT_FILE=".claude-reviews/.runs/current"

if [ ! -f "$CURRENT_FILE" ]; then
  echo "ERROR: no active run. Call init-run.sh first." >&2
  exit 3
fi

RUN_ID="$(cat "$CURRENT_FILE")"
MANIFEST=".claude-reviews/.runs/$RUN_ID/manifest.json"

if [ ! -f "$MANIFEST" ]; then
  echo "ERROR: manifest not found at $MANIFEST" >&2
  exit 3
fi

if [ $# -lt 1 ]; then
  echo "Usage: record-step.sh <subcommand> [args...]" >&2
  exit 2
fi

CMD="$1"; shift

# Helper: in-place jq update
patch() {
  local filter="$1"
  local tmp; tmp="$(mktemp)"
  jq "$filter" "$MANIFEST" > "$tmp"
  mv "$tmp" "$MANIFEST"
}

valid_phase() {
  case "$1" in
    0_preflight|1_branch_context|2_doc_gate|3_validation|4_diff_scoping|5_specialists|6_codex|7_merge|7a_synthesis|8_report) return 0 ;;
    *) return 1 ;;
  esac
}

valid_specialist() {
  case "$1" in
    conventions|mobile-security|correctness|overengineering|codex|naive) return 0 ;;
    *) return 1 ;;
  esac
}

valid_stream() {
  case "$1" in A|B|C) return 0 ;; *) return 1 ;; esac
}

valid_mode() {
  case "$1" in default|quick) return 0 ;; *) return 1 ;; esac
}

valid_validation_kind() {
  case "$1" in lint|analyzer|test) return 0 ;; *) return 1 ;; esac
}

valid_validation_status() {
  case "$1" in pass|fail|skipped|timeout) return 0 ;; *) return 1 ;; esac
}

valid_severity() {
  case "$1" in blocker|critical|major|minor|info|suppressed) return 0 ;; *) return 1 ;; esac
}

case "$CMD" in
  phase-done)
    [ $# -eq 1 ] || { echo "Usage: phase-done <phase>" >&2; exit 2; }
    valid_phase "$1" || { echo "ERROR: invalid phase '$1'" >&2; exit 4; }
    TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    patch ".phases.\"$1\".done = true | .phases.\"$1\".finished_at = \"$TS\""
    ;;

  d1-asked)
    [ $# -eq 1 ] || { echo "Usage: d1-asked <method>" >&2; exit 2; }
    case "$1" in ask|gh|default|manual) ;; *) echo "ERROR: invalid method '$1'" >&2; exit 4 ;; esac
    patch ".phases.\"1_branch_context\".d1_asked = true | .phases.\"1_branch_context\".method = \"$1\""
    ;;

  claude-md-read)
    patch '.phases."2_doc_gate".claude_md_read = true'
    ;;

  doc-read)
    [ $# -eq 1 ] || { echo "Usage: doc-read <path>" >&2; exit 2; }
    patch ".phases.\"2_doc_gate\".docs_read += [\"$1\"]"
    ;;

  rules-extracted)
    patch '.phases."2_doc_gate".rules_extracted = true'
    ;;

  set-base)
    [ $# -eq 2 ] || { echo "Usage: set-base <branch> <merge_base_sha>" >&2; exit 2; }
    patch ".base = \"$1\" | .merge_base = \"$2\""
    ;;

  validation)
    [ $# -ge 2 ] || { echo "Usage: validation <kind> <status> [duration_s]" >&2; exit 2; }
    valid_validation_kind "$1" || { echo "ERROR: invalid kind '$1'" >&2; exit 4; }
    valid_validation_status "$2" || { echo "ERROR: invalid status '$2'" >&2; exit 4; }
    DURATION="${3:-null}"
    patch ".phases.\"3_validation\".\"$1\" = {\"status\":\"$2\",\"duration_s\":$DURATION}"
    ;;

  diff-stat)
    [ $# -eq 2 ] || { echo "Usage: diff-stat <files_total> <files_reviewed>" >&2; exit 2; }
    patch ".phases.\"4_diff_scoping\".files_total = $1 | .phases.\"4_diff_scoping\".files_reviewed = $2"
    ;;

  specialists-planned)
    [ $# -eq 1 ] || { echo "Usage: specialists-planned <name1,name2,...>" >&2; exit 2; }
    LIST_JSON=$(echo "$1" | tr ',' '\n' | jq -R . | jq -s .)
    patch ".phases.\"4_diff_scoping\".specialists_planned = $LIST_JSON"
    ;;

  agent-dispatched)
    [ $# -eq 3 ] || { echo "Usage: agent-dispatched <task_id> <specialist> <stream>" >&2; exit 2; }
    valid_specialist "$2" || { echo "ERROR: invalid specialist '$2'" >&2; exit 4; }
    valid_stream "$3" || { echo "ERROR: invalid stream '$3' (use A, B, or C)" >&2; exit 4; }
    TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    patch ".phases.\"5_specialists\".streams.\"$3\".dispatched += [{\"task_id\":\"$1\",\"specialist\":\"$2\",\"ts\":\"$TS\"}]"
    ;;

  stream-model)
    [ $# -eq 2 ] || { echo "Usage: stream-model <stream> <model>" >&2; exit 2; }
    valid_stream "$1" || { echo "ERROR: invalid stream '$1'" >&2; exit 4; }
    patch ".phases.\"5_specialists\".streams.\"$1\".model = \"$2\""
    ;;

  mode)
    [ $# -eq 1 ] || { echo "Usage: mode <default|quick>" >&2; exit 2; }
    valid_mode "$1" || { echo "ERROR: invalid mode '$1'" >&2; exit 4; }
    patch ".mode = \"$1\""
    ;;

  synthesis-dispatched)
    [ $# -eq 1 ] || { echo "Usage: synthesis-dispatched <task_id>" >&2; exit 2; }
    patch ".phases.\"7a_synthesis\".agent_dispatched = true | .phases.\"7a_synthesis\".task_id = \"$1\""
    ;;

  synthesis-stats)
    [ $# -eq 4 ] || { echo "Usage: synthesis-stats <consensus> <partial> <unique> <disagreement>" >&2; exit 2; }
    patch ".phases.\"7a_synthesis\".consensus = $1 | .phases.\"7a_synthesis\".partial = $2 | .phases.\"7a_synthesis\".unique = $3 | .phases.\"7a_synthesis\".disagreement = $4"
    ;;

  codex)
    [ $# -ge 1 ] || { echo "Usage: codex <available:true|false> [exit_code]" >&2; exit 2; }
    case "$1" in true|false) ;; *) echo "ERROR: available must be true|false" >&2; exit 4 ;; esac
    EXIT_CODE="${2:-null}"
    patch ".phases.\"6_codex\".attempted = true | .phases.\"6_codex\".available = $1 | .phases.\"6_codex\".exit = $EXIT_CODE"
    ;;

  findings)
    [ $# -eq 2 ] || { echo "Usage: findings <severity> <count>" >&2; exit 2; }
    valid_severity "$1" || { echo "ERROR: invalid severity '$1'" >&2; exit 4; }
    patch ".findings.\"$1\" = $2"
    ;;

  report-path)
    [ $# -eq 1 ] || { echo "Usage: report-path <path>" >&2; exit 2; }
    patch ".phases.\"8_report\".path = \"$1\""
    ;;

  warn)
    [ $# -ge 1 ] || { echo "Usage: warn <text>" >&2; exit 2; }
    TEXT="$*"
    patch ".warnings += [\"$(echo "$TEXT" | sed 's/"/\\"/g')\"]"
    ;;

  error)
    [ $# -ge 1 ] || { echo "Usage: error <text>" >&2; exit 2; }
    TEXT="$*"
    patch ".errors += [\"$(echo "$TEXT" | sed 's/"/\\"/g')\"]"
    ;;

  finish)
    TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    patch ".finished_at = \"$TS\""
    ;;

  show)
    cat "$MANIFEST"
    ;;

  *)
    echo "ERROR: unknown subcommand '$CMD'" >&2
    echo "Run with no args to see usage." >&2
    exit 2
    ;;
esac
