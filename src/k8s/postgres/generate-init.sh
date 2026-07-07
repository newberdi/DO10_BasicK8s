#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Если запущено из src/ — используем pwd
# Если из другого места — ищем src/

if [ -f "services/database/init.sql" ]; then
    SRC_DIR="$(pwd)"
elif [ -f "src/services/database/init.sql" ]; then
    SRC_DIR="$(pwd)/src"
else
    SRC_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
fi

INIT_SQL="$SRC_DIR/services/database/init.sql"
OUTPUT="$SCRIPT_DIR/postgres-init-configmap.yml"

# echo "SRC_DIR: $SRC_DIR"
# echo "INIT_SQL: $INIT_SQL"
# echo "OUTPUT: $OUTPUT"

kubectl create configmap postgres-init-script \
  --from-file=init.sql="$INIT_SQL" \
  -n devops-app \
  --dry-run=client -o yaml > "$OUTPUT"