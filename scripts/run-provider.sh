#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$SCRIPT_DIR/.."
PROVIDER_DIR="$PROJECT_DIR/src/provider"

cd "$PROVIDER_DIR"
uv run uvicorn app.main:app --reload
