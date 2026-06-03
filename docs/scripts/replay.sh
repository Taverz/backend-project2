#!/bin/bash
# replay.sh — Воспроизвести контекст AI-сессии для отладки.
# Использование: ./docs/scripts/replay.sh <session_id> [--turn N]
#
# Пример:
#   ./docs/scripts/replay.sh 25468bf4
#   ./docs/scripts/replay.sh 25468bf4 --turn 5
#
# Результат: выводит system prompt + все сообщения до N-го хода в читаемом виде.
# Можно скопировать и отправить в новую сессию CodeWhale для воспроизведения.

set -euo pipefail

SESSION_ID="${1:?Usage: replay.sh <session_id> [--turn N]}"
TURN=""

# Parse optional --turn flag
while [[ $# -gt 0 ]]; do
  case "$1" in
    --turn) TURN="$2"; shift 2 ;;
    --turn=*) TURN="${1#*=}"; shift ;;
    *) shift ;;
  esac
done

TRANSCRIPT="docs/transcripts/${SESSION_ID}.jsonl"

if [ ! -f "$TRANSCRIPT" ]; then
  echo "❌ Transcript not found: $TRANSCRIPT"
  echo ""
  echo "Available transcripts:"
  ls -1 docs/transcripts/*.jsonl 2>/dev/null || echo "(none)"
  exit 1
fi

echo "╔══════════════════════════════════════════════════╗"
echo "║        Chirp AI Session Replay                  ║"
echo "║  Session: ${SESSION_ID}                          "
if [ -n "$TURN" ]; then
  echo "║  Up to turn: ${TURN}                               "
fi
echo "╚══════════════════════════════════════════════════╝"
echo ""

# Extract header — system prompt from first user message's <turn_meta>
# In our format, turn_meta is in the first user message
FIRST_USER=$(python3 -c "
import json, sys
with open('$TRANSCRIPT') as f:
    for line in f:
        msg = json.loads(line)
        if msg.get('role') == 'user':
            for block in msg.get('content', []):
                if block.get('type') == 'text' and '<turn_meta>' not in block.get('text', ''):
                    print(block['text'][:200] + '...' if len(block['text']) > 200 else block['text'])
                    sys.exit(0)
")

echo "=== FIRST USER PROMPT ==="
echo "$FIRST_USER"
echo ""

# Count total turns
TOTAL=$(python3 -c "
import json
count = 0
with open('$TRANSCRIPT') as f:
    for line in f:
        msg = json.loads(line)
        if msg.get('role') == 'user':
            count += 1
print(count)
")

echo "=== SESSION OVERVIEW ==="
echo "Total user messages: $TOTAL"
echo ""

# Extract messages up to TURN
PYTHON_SCRIPT="
import json, sys

max_turn = int('${TURN:-999999}')
turn = 0
with open('$TRANSCRIPT') as f:
    for line in f:
        msg = json.loads(line)
        role = msg.get('role', '?')
        idx = msg.get('index', '?')

        if role == 'user':
            turn += 1
            if turn > max_turn:
                break

        # Format output
        if role == 'user':
            texts = []
            for b in msg.get('content', []):
                if b.get('type') == 'text':
                    t = b['text']
                    # Skip turn_meta blocks
                    if '<turn_meta>' in t:
                        continue
                    texts.append(t)
                elif b.get('type') == 'tool_result':
                    texts.append(f'[TOOL RESULT: {b.get(\"tool_use_id\",\"?\")}]')
            if texts:
                print(f'--- User (turn {turn}) ---')
                for t in texts:
                    print(t[:500])
                    if len(t) > 500:
                        print('  ... [truncated]')
                print()

        elif role == 'assistant':
            texts = []
            tools = []
            for b in msg.get('content', []):
                if b.get('type') == 'thinking':
                    chars = b.get('chars', 0)
                    texts.append(f'[thinking: {chars} chars]')
                elif b.get('type') == 'tool_use':
                    tools.append(f'  → {b.get(\"name\",\"?\")}')
                elif b.get('type') == 'text':
                    texts.append(b['text'])
            if texts:
                print(f'--- Assistant ---')
                for t in texts:
                    print(t)
            if tools:
                print('Tool calls:')
                for t in tools:
                    print(t)
            print()
"

python3 -c "$PYTHON_SCRIPT"

echo "=== END OF REPLAY ==="
echo "To reproduce, copy the content above into a new CodeWhale session."
