#!/bin/bash

STRATEGY=$1

if [ "$STRATEGY" == "recreate" ]; then
    MANIFEST="k8s/strategies/recreate-strategy.yml"
elif [ "$STRATEGY" == "rolling" ]; then
    MANIFEST="k8s/strategies/rolling-strategy.yml"
else
    echo "Укажите: recreate или rolling"
    exit 1
fi

echo "========================================="
echo " Развертывание со стратегией: $STRATEGY"
echo "     Начало: $(date '+%H:%M:%S')"
echo "========================================="

START_TIME=$(date +%s)

kubectl apply -f $MANIFEST

kubectl rollout status deployment/gateway-service -n devops-app --timeout=300s

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo ""
echo "========================================="
echo "   Развертывание завершено!"
echo "   Конец: $(date '+%H:%M:%S')"
echo "   Общее время: ${DURATION} секунд"