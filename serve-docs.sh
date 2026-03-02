#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SITE="$ROOT/docs/site"
PORT="${1:-3000}"

echo "Assembling docs/site..."

# Clean previously assembled artifacts
rm -rf \
  "$SITE/images" \
  "$SITE/trigger-actions-framework" \
  "$SITE/custom-objects" \
  "$SITE/index.md" \
  "$SITE/contributing.md" \
  "$SITE/code-of-conduct.md"

# Mirror the GitHub Actions assembly steps
cp -r "$ROOT/images"                        "$SITE/images"
cp -r "$ROOT/docs/trigger-actions-framework" "$SITE/trigger-actions-framework"
cp -r "$ROOT/docs/custom-objects"            "$SITE/custom-objects"
cp    "$ROOT/docs/index.md"                  "$SITE/index.md"
cp    "$ROOT/docs/contributing.md"           "$SITE/contributing.md"
cp    "$ROOT/docs/code-of-conduct.md"        "$SITE/code-of-conduct.md"

echo "Serving at http://localhost:$PORT - press Ctrl+C to stop"
python3 -m http.server "$PORT" --directory "$SITE"
