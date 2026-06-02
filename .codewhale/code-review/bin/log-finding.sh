#!/usr/bin/env bash
# log-finding.sh — write a calibration record to ~/.claude/code-review/calibration.jsonl
#
# Usage (via stdin):
#   echo '{"fingerprint":"...","specialist":"...","confidence_initial":N,"verdict":"confirmed|false-positive|ambiguous","project":"...","branch":"..."}' | log-finding.sh
#
# Or with a file argument:
#   log-finding.sh /path/to/finding.json
#
# Adds a `ts` field (ISO 8601) and appends one line to calibration.jsonl.

set -euo pipefail

CALIB_DIR="${HOME}/.claude/code-review"
CALIB_FILE="${CALIB_DIR}/calibration.jsonl"

mkdir -p "$CALIB_DIR"
touch "$CALIB_FILE"

if [ $# -gt 0 ] && [ -f "$1" ]; then
  RAW=$(cat "$1")
elif [ ! -t 0 ]; then
  RAW=$(cat)
else
  echo "Usage: log-finding.sh < input.json   OR   log-finding.sh path/to/finding.json" >&2
  exit 2
fi

# Minimal validation that input is a JSON object
if ! echo "$RAW" | grep -qE '^\s*\{'; then
  echo "ERROR: input does not look like JSON object" >&2
  exit 3
fi

TS=$(date -u +%Y-%m-%dT%H:%M:%SZ)

# Inject ts into the JSON. If jq is available — use it, otherwise fall back to sed.
if command -v jq >/dev/null 2>&1; then
  echo "$RAW" | jq --arg ts "$TS" '. + {ts: $ts}' -c >> "$CALIB_FILE"
else
  # Fallback: insert "ts":"..." right after the opening brace. Doesn't handle whitespace
  # nuances, but works for our compact JSON case.
  COMPACT=$(echo "$RAW" | tr -d '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')
  if [ "${COMPACT:0:1}" = "{" ] && [ "${COMPACT:1:1}" = "}" ]; then
    # Empty object — just emit ts
    echo "{\"ts\":\"$TS\"}" >> "$CALIB_FILE"
  else
    # Insert after the opening {
    PATCHED=$(echo "$COMPACT" | sed "s/^{/{\"ts\":\"$TS\",/")
    echo "$PATCHED" >> "$CALIB_FILE"
  fi
fi

# Return the path so callers can verify the write.
echo "$CALIB_FILE"
