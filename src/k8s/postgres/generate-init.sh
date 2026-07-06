#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

INIT_SQL_PATH="$SCRIPT_DIR/app/services/database/init.sql"
OUTPUT_PATH="$SCRIPT_DIR/postgres-init-configmap.yml"

kubectl create configmap postgres-init-script \
  --from-file=init.sql="$INIT_SQL_PATH" \
  -n devops-app \
  --dry-run=client -o yaml > "$OUTPUT_PATH"