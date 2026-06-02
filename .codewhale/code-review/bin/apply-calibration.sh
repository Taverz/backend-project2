#!/usr/bin/env bash
# apply-calibration.sh — read ~/.claude/code-review/calibration.jsonl and return
# aggregate fingerprint statistics for the current project.
#
# Usage:
#   bash apply-calibration.sh <project_slug>
#
# Stdout (JSON object):
# {
#   "boost": ["fingerprint1", ...],            # ≥ 3 confirmed in a row → boost +1
#   "depress": ["fingerprintN", ...],          # ≥ 3 false-positive → depress -2 or suppress
#   "specialist_fp_rates": {
#      "conventions:naming": 0.6,              # 60% FP rate
#      ...
#    }
# }
#
# Logic:
# - boost: confidence_initial < 9 AND ≥ 3 confirmed for that fingerprint within last 10 records
# - depress: ≥ 3 false-positive for the fingerprint in last 10
# - specialist_fp_rates: FP percentage by category within specialist (for category-level adaptive gating)

set -euo pipefail

CALIB_FILE="${HOME}/.claude/code-review/calibration.jsonl"

if [ ! -f "$CALIB_FILE" ]; then
  # No history — empty result
  echo '{"boost":[],"depress":[],"specialist_fp_rates":{}}'
  exit 0
fi

PROJECT="${1:-unknown}"

if ! command -v jq >/dev/null 2>&1; then
  # Without jq we can only do crude processing. Return empty result.
  echo '{"boost":[],"depress":[],"specialist_fp_rates":{},"warning":"jq not installed, calibration disabled"}'
  exit 0
fi

# Filter by project, keep last 100 records
PROJECT_RECORDS=$(grep -F "\"project\":\"$PROJECT\"" "$CALIB_FILE" | tail -100 || true)

if [ -z "$PROJECT_RECORDS" ]; then
  echo '{"boost":[],"depress":[],"specialist_fp_rates":{}}'
  exit 0
fi

# 1. Boost: fingerprints with ≥ 3 confirmed in last records
BOOST=$(echo "$PROJECT_RECORDS" \
  | jq -r 'select(.verdict == "confirmed") | .fingerprint' 2>/dev/null \
  | sort | uniq -c | awk '$1 >= 3 {print $2}' | jq -R . | jq -s . || echo '[]')

# 2. Depress: fingerprints with ≥ 3 false-positive in last records
DEPRESS=$(echo "$PROJECT_RECORDS" \
  | jq -r 'select(.verdict == "false-positive") | .fingerprint' 2>/dev/null \
  | sort | uniq -c | awk '$1 >= 3 {print $2}' | jq -R . | jq -s . || echo '[]')

# 3. Specialist+category FP rates
# For each specialist+category pair, compute the false-positive percentage.
RATES=$(echo "$PROJECT_RECORDS" \
  | jq -r '. | "\(.specialist):\(.fingerprint | split(":")[1] // "unknown") \(.verdict)"' 2>/dev/null \
  | awk '
      {
        key = $1
        verdict = $2
        total[key]++
        if (verdict == "false-positive") fp[key]++
      }
      END {
        printf "{"
        first = 1
        for (k in total) {
          if (total[k] >= 3) {
            rate = (fp[k] + 0) / total[k]
            if (first) first = 0; else printf ","
            printf "\"%s\":%.2f", k, rate
          }
        }
        printf "}"
      }' || echo '{}')

# Final JSON
jq -n \
  --argjson boost "$BOOST" \
  --argjson depress "$DEPRESS" \
  --argjson rates "$RATES" \
  '{boost: $boost, depress: $depress, specialist_fp_rates: $rates}'
