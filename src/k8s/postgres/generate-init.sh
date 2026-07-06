#!/bin/bash

# Если запущено из src/ — используем pwd
# Если из другого места — ищем src/

if [ -f "app/services/database/init.sql" ]; then
    SRC_DIR="$(pwd)"
elif [ -f "src/app/services/database/init.sql" ]; then
    SRC_DIR="$(pwd)/src"
else
    SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    SRC_DIR="$(cd "$SCRIPT_DIR/../.." && pwd)"
fi

INIT_SQL="$SRC_DIR/app/services/database/init.sql"
OUTPUT="$SCRIPT_DIR/postgres-init-configmap.yml"

echo "SRC_DIR: $SRC_DIR"
echo "INIT_SQL: $INIT_SQL"

kubectl create configmap postgres-init-script \
  --from-file=init.sql="$INIT_SQL" \
  -n devops-app \
  --dry-run=client -o yaml > "$OUTPUT"