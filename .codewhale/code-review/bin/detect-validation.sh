#!/usr/bin/env bash
# detect-validation.sh — detect linter/analyzer/test commands for the project.
# Returns a JSON object on stdout. No side effects.
#
# Priority order:
# 1. CLAUDE.md `## Health Stack` or `## Validation` section — highest priority
# 2. Makefile with matching targets — next
# 3. Auto-detect by config files (pubspec.yaml, package.json, etc.)
#
# Usage:
#   bash detect-validation.sh
#
# Output (JSON):
# {
#   "lint": "make lint",
#   "analyzer": "dart analyze .",
#   "test": "make test",
#   "source": "makefile" | "claude_md" | "auto"
# }

set -euo pipefail

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || pwd)"
cd "$REPO_ROOT"

LINT=""
ANALYZER=""
TEST=""
SOURCE="auto"

# 1. Try CLAUDE.md
if [ -f CLAUDE.md ]; then
  # Look for `## Health Stack` or `## Validation` section
  if grep -qiE "^## (Health Stack|Validation)" CLAUDE.md 2>/dev/null; then
    SECTION=$(awk '/^## (Health Stack|Validation)/,/^## /' CLAUDE.md | sed '$d' || true)
    while IFS= read -r line; do
      # Parse lines like "lint: <command>" or "- lint: <command>"
      if echo "$line" | grep -qE '^[[:space:]-]*lint:[[:space:]]+'; then
        LINT=$(echo "$line" | sed -E 's/^[[:space:]-]*lint:[[:space:]]+//')
      fi
      if echo "$line" | grep -qE '^[[:space:]-]*(analyzer|typecheck):[[:space:]]+'; then
        ANALYZER=$(echo "$line" | sed -E 's/^[[:space:]-]*(analyzer|typecheck):[[:space:]]+//')
      fi
      if echo "$line" | grep -qE '^[[:space:]-]*(test|tests):[[:space:]]+'; then
        TEST=$(echo "$line" | sed -E 's/^[[:space:]-]*(test|tests):[[:space:]]+//')
      fi
    done <<< "$SECTION"
    if [ -n "$LINT" ] || [ -n "$ANALYZER" ] || [ -n "$TEST" ]; then
      SOURCE="claude_md"
    fi
  fi
fi

# 2. Makefile fallback
if [ -z "$LINT$ANALYZER$TEST" ] && [ -f Makefile ]; then
  if grep -qE "^lint:" Makefile 2>/dev/null; then
    LINT="make lint"
    SOURCE="makefile"
  fi
  if grep -qE "^(analyze|analyzer|typecheck):" Makefile 2>/dev/null; then
    ANALYZER="make analyze"
    [ "$SOURCE" = "auto" ] && SOURCE="makefile"
  fi
  if grep -qE "^test:" Makefile 2>/dev/null; then
    TEST="make test"
    [ "$SOURCE" = "auto" ] && SOURCE="makefile"
  fi
fi

# 3. Auto-detect by project type
if [ -z "$LINT" ]; then
  if [ -f pubspec.yaml ]; then
    LINT="dart format --line-length 120 --set-exit-if-changed ."
    [ -z "$ANALYZER" ] && ANALYZER="dart analyze ."
    [ -z "$TEST" ] && TEST="flutter test"
  elif [ -f package.json ]; then
    if grep -q '"lint"' package.json 2>/dev/null; then
      LINT="npm run lint"
    fi
    if grep -q '"typecheck"' package.json 2>/dev/null; then
      ANALYZER="npm run typecheck"
    elif [ -f tsconfig.json ]; then
      ANALYZER="npx tsc --noEmit"
    fi
    if grep -q '"test"' package.json 2>/dev/null; then
      TEST="npm test"
    fi
  elif [ -f Cargo.toml ]; then
    LINT="cargo clippy -- -D warnings"
    ANALYZER="cargo check"
    TEST="cargo test"
  elif [ -f go.mod ]; then
    LINT="go vet ./..."
    ANALYZER="go build ./..."
    TEST="go test ./..."
  elif [ -f pyproject.toml ] || [ -f requirements.txt ]; then
    if command -v ruff >/dev/null 2>&1; then
      LINT="ruff check ."
    fi
    if command -v mypy >/dev/null 2>&1; then
      ANALYZER="mypy ."
    fi
    if command -v pytest >/dev/null 2>&1; then
      TEST="pytest"
    fi
  elif [ -f Gemfile ]; then
    if [ -f .rubocop.yml ] || grep -q rubocop Gemfile 2>/dev/null; then
      LINT="bundle exec rubocop"
    fi
    if grep -q rspec Gemfile 2>/dev/null; then
      TEST="bundle exec rspec"
    elif [ -d test ]; then
      TEST="rake test"
    fi
  fi
fi

# Emit JSON. Empty fields become null.
emit() {
  if [ -z "$1" ]; then
    printf 'null'
  else
    # Escape backslashes and double-quotes
    printf '"%s"' "$(echo "$1" | sed 's/\\/\\\\/g; s/"/\\"/g')"
  fi
}

printf '{\n'
printf '  "lint": '; emit "$LINT"; printf ',\n'
printf '  "analyzer": '; emit "$ANALYZER"; printf ',\n'
printf '  "test": '; emit "$TEST"; printf ',\n'
printf '  "source": "%s"\n' "$SOURCE"
printf '}\n'
