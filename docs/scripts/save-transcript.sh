#!/bin/bash
# save-transcript.sh — Сохранить текущий transcript сессии на диск.
# Вызывается из CodeWhale при команде «запиши в лог».
#
# Использование:
#   ./docs/scripts/save-transcript.sh <session_id> <source_path> [--traces]
#
# <source_path> — файл JSONL (обычно из артефакта RLM)
# --traces — также сгенерировать трассы

set -euo pipefail

SESSION_ID="${1:?Usage: save-transcript.sh <session_id> <source_path>}"
SOURCE="${2:?Usage: save-transcript.sh <session_id> <source_path>}"
GENERATE_TRACES=false

for arg in "$@"; do
  case "$arg" in
    --traces) GENERATE_TRACES=true ;;
  esac
done

TARGET="docs/transcripts/${SESSION_ID}.jsonl"
META="docs/transcripts/${SESSION_ID}.meta.json"
INDEX="docs/transcripts/index.json"

# Ensure dir
mkdir -p docs/transcripts

# Calculate date from session_id prefix (UNIX timestamp heuristic)
# Actually use current date
DATE=$(date -u +%Y-%m-%d)

# Save transcript
cp "$SOURCE" "$TARGET"
LINES=$(wc -l < "$TARGET")
SIZE=$(wc -c < "$TARGET" | tr -d ' ')

echo "✅ Transcript saved: $TARGET"
echo "   Lines: $LINES, Size: ${SIZE} bytes"

# Save metadata
cat > "$META" << EOF
{
  "session_id": "${SESSION_ID}",
  "date": "${DATE}",
  "lines": ${LINES},
  "size_bytes": ${SIZE},
  "source": "${SOURCE}",
  "generated_at": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
}
EOF

echo "✅ Metadata saved: $META"

# Update index
if [ ! -f "$INDEX" ]; then
  echo '{"sessions":[]}' > "$INDEX"
fi

python3 -c "
import json
with open('$INDEX') as f:
    idx = json.load(f)
entry = {'session_id': '${SESSION_ID}', 'date': '${DATE}', 'lines': ${LINES}, 'size_bytes': ${SIZE}}
# Avoid duplicates
idx['sessions'] = [s for s in idx['sessions'] if s['session_id'] != '${SESSION_ID}']
idx['sessions'].append(entry)
# Sort by date desc
idx['sessions'].sort(key=lambda s: s['date'], reverse=True)
with open('$INDEX', 'w') as f:
    json.dump(idx, f, indent=2)
"

echo "✅ Index updated: $INDEX"

# Generate traces
if [ "$GENERATE_TRACES" = true ]; then
  python3 docs/scripts/generate-traces.py "$TARGET"
fi

echo ""
echo "📊 Summary:"
echo "  Session:  ${SESSION_ID}"
echo "  Date:     ${DATE}"
echo "  Lines:    ${LINES}"
echo "  Traces:   $([ "$GENERATE_TRACES" = true ] && echo 'yes' || echo 'no (use --traces)')"
