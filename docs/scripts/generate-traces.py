#!/usr/bin/env python3
"""
generate-traces.py — Из JSONL transcript'а в структурированные трассы (spans).

Использование:
  python3 docs/scripts/generate-traces.py docs/transcripts/25468bf4.jsonl

Результат: docs/transcripts/25468bf4.traces.json
"""

import json
import sys
import os
from datetime import datetime


def parse_transcript(path):
    """Читает JSONL transcript и возвращает список сообщений."""
    messages = []
    with open(path) as f:
        for line in f:
            line = line.strip()
            if line:
                messages.append(json.loads(line))
    return messages


def build_traces(messages):
    """
    Из плоского списка сообщений строит структурированные трассы.
    Каждый user-ход → root span, вложенные assistant-спаны.
    """
    traces = {
        "trace_id": os.path.basename(path).replace(".jsonl", ""),
        "generated_at": datetime.utcnow().isoformat() + "Z",
        "total_messages": len(messages),
        "spans": []
    }

    current_turn = 0
    current_span = None
    assistant_spans = []

    for msg in messages:
        role = msg.get("role", "?")
        idx = msg.get("index", 0)

        if role == "user":
            # Check if this is a turn_meta or a real user message
            texts = [b.get("text", "") for b in msg.get("content", [])
                     if b.get("type") == "text"]
            full_text = " ".join(texts)

            # Skip pure tool_result messages
            is_tool_result = any(b.get("type") == "tool_result"
                                 for b in msg.get("content", []))
            if is_tool_result:
                continue

            current_turn += 1
            user_text = full_text[:200] if "<turn_meta>" in full_text else full_text[:200]

            if current_span:
                # Close previous span
                pass

            current_span = {
                "id": f"turn-{current_turn}",
                "parent_id": None,
                "name": f"user: {user_text[:60].strip()}",
                "kind": "user_input",
                "children": []
            }
            traces["spans"].append(current_span)

        elif role == "assistant":
            if current_span is None:
                continue

            for block in msg.get("content", []):
                if block.get("type") == "thinking":
                    assistant_spans.append({
                        "id": f"think-{idx}",
                        "parent_id": current_span["id"],
                        "name": "thinking",
                        "kind": "reasoning",
                        "chars": block.get("chars", 0)
                    })

                elif block.get("type") == "tool_use":
                    tool_name = block.get("name", "?")
                    tool_input = block.get("input", {})
                    span = {
                        "id": block.get("id", "tool-unknown"),
                        "parent_id": current_span["id"],
                        "name": tool_name,
                        "kind": "tool_call",
                        "input_preview": str(tool_input)[:200]
                    }
                    current_span["children"].append(span)

                elif block.get("type") == "text":
                    span = {
                        "id": f"resp-{idx}",
                        "parent_id": current_span["id"],
                        "name": "assistant_response",
                        "kind": "response",
                        "text_preview": block.get("text", "")[:200]
                    }
                    current_span["children"].append(span)

    # Add thinking spans to their parent
    for s in assistant_spans:
        parent_id = s["parent_id"]
        for span in traces["spans"]:
            if span["id"] == parent_id:
                span["children"].append(s)
                break

    return traces


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: generate-traces.py <transcript.jsonl>")
        sys.exit(1)

    path = sys.argv[1]
    if not os.path.exists(path):
        print(f"File not found: {path}")
        sys.exit(1)

    messages = parse_transcript(path)
    traces = build_traces(messages)

    out_path = path.replace(".jsonl", ".traces.json")
    with open(out_path, "w", encoding="utf-8") as f:
        json.dump(traces, f, indent=2, ensure_ascii=False)

    print(f"✅ Generated: {out_path}")
    print(f"   Spans: {len(traces['spans'])}")
    print(f"   Messages processed: {len(messages)}")
