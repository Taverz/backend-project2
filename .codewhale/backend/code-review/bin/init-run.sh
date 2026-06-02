#!/usr/bin/env bash
# init-run.sh — start a new code-review run. Creates a per-run manifest and
# returns RUN_ID on stdout. The manifest is the single source of truth for
# whether each phase actually executed.
#
# MANDATORY first call in Phase 0 of the skill. Without an active manifest,
# validate-run.sh refuses and the report cannot be written.
#
# Usage:
#   RUN_ID=$(bash ~/.claude/skills/code-review/bin/init-run.sh)
#
# Side effects:
#   - mkdir .claude-reviews/.runs/<RUN_ID>/
#   - write manifest.json with a skeleton schema
#   - write .claude-reviews/.runs/current with the RUN_ID
#
# Stdout: <RUN_ID>
# Stderr: human-readable progress

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

mkdir -p .claude-reviews/.runs

RUN_ID="$(date -u +%Y%m%dT%H%M%SZ)-$(printf '%04x' "$RANDOM")"
RUN_DIR=".claude-reviews/.runs/$RUN_ID"
mkdir -p "$RUN_DIR"

BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null || echo unknown)"
BRANCH="$(printf '%s' "$BRANCH" | tr -d '\n\r' | sed 's/"/\\"/g')"
TS="$(date -u +%Y-%m-%dT%H:%M:%SZ)"

cat > "$RUN_DIR/manifest.json" <<JSON
{
  "run_id": "$RUN_ID",
  "schema_version": 2,
  "started_at": "$TS",
  "finished_at": null,
  "repo_root": "$REPO_ROOT",
  "branch": "$BRANCH",
  "base": null,
  "merge_base": null,
  "mode": "default",
  "phases": {
    "0_preflight":      {"done": false, "started_at": "$TS"},
    "1_branch_context": {"done": false, "d1_asked": false, "method": null},
    "2_doc_gate":       {"done": false, "claude_md_read": false, "docs_read": [], "rules_extracted": false},
    "3_validation":     {"done": false, "lint": null, "analyzer": null, "test": null},
    "4_diff_scoping":   {"done": false, "files_total": 0, "files_reviewed": 0, "specialists_planned": []},
    "5_specialists":    {
      "done": false,
      "streams": {
        "A": {"model": null, "dispatched": []},
        "B": {"model": null, "dispatched": []},
        "C": {"model": null, "dispatched": []}
      }
    },
    "6_codex":          {"done": false, "attempted": false, "available": null, "exit": null},
    "7_merge":          {"done": false, "findings_count": null},
    "7a_synthesis":     {"done": false, "agent_dispatched": false, "task_id": null,
                         "consensus": 0, "partial": 0, "unique": 0, "disagreement": 0},
    "8_report":         {"done": false, "path": null}
  },
  "findings": {"blocker": 0, "critical": 0, "major": 0, "minor": 0, "info": 0, "suppressed": 0},
  "warnings": [],
  "errors": []
}
JSON

echo "$RUN_ID" > .claude-reviews/.runs/current

echo "init-run: created $RUN_DIR/manifest.json" >&2
echo "init-run: branch=$BRANCH" >&2
echo "$RUN_ID"
