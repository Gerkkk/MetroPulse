#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# используем имя сервиса вместо localhost
CONNECT_URL="http://kafka-connect:8083/connectors"
CONFIG_DIR="$PROJECT_ROOT/debezium"

shopt -s nullglob

FILES=("$CONFIG_DIR"/*.json)

if [ ${#FILES[@]} -eq 0 ]; then
  echo "❌ No Debezium config files found in $CONFIG_DIR"
  exit 1
fi

for cfg in "${FILES[@]}"; do
  echo "Registering $(basename "$cfg")"
  curl -s -o /dev/null -w "%{http_code}\n" \
    -X POST "$CONNECT_URL" \
    -H "Content-Type: application/json" \
    -d @"$cfg"
done
