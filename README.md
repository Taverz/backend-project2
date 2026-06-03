

Готово. Система Logs + Traces для AI-сессий.

Что получилось

docs/
├── scripts/
│   ├── save-transcript.sh      ← сохранить transcript + обновить index
│   ├── generate-traces.py      ← JSONL → структурированные трассы
│   └── replay.sh               ← воспроизвести контекст
└── transcripts/
    └── index.json              ← индекс сессий

save-transcript.sh

./docs/scripts/save-transcript.sh 25468bf4 /tmp/transcript.jsonl --traces

Делает:
- Копирует JSONL → docs/transcripts/25468bf4.jsonl
- Создаёт docs/transcripts/25468bf4.meta.json
- Обновляет docs/transcripts/index.json
- При  --traces генерирует 25468bf4.traces.json со спанами

replay.sh

./docs/scripts/replay.sh 25468bf4            # вся сессия
./docs/scripts/replay.sh 25468bf4 --turn 5   # до 5-го хода

Выводит читаемый промт, готовый к копированию в новую сессию CodeWhale.

Traces (пример)

{
  "trace_id": "25468bf4",
  "spans": [{
    "id": "turn-5",
    "name": "user: создать follow модуль",
    "children": [
      {"name": "thinking", "chars": 450},
      {"name": "write_file", "input_preview": "{...}"},
      {"name": "tool_call", "name": "shell"},
      {"name": "assistant_response", "text_preview": "..."}
    ]
  }]
}

Процесс при «запиши в лог»

1. RLM: session://active/transcript → получаю JSONL
2. save-transcript.sh <session_id> <jsonl> --traces
3. Собираю метрики → AI-LOG.md
4. Сохраняю метрики → docs/metrics/