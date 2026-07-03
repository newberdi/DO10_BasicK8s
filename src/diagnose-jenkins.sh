#!/bin/bash

POD_NAME=$(kubectl get pods -n jenkins -l app=jenkins -o jsonpath='{.items[0].metadata.name}')

echo "=== Проверка сети ==="
kubectl exec -n jenkins $POD_NAME -- ping -c 3 8.8.8.8
kubectl exec -n jenkins $POD_NAME -- nslookup updates.jenkins.io

echo "=== Проверка SSL ==="
kubectl exec -n jenkins $POD_NAME -- curl -I https://updates.jenkins.io

echo "=== Проверка диска ==="
kubectl exec -n jenkins $POD_NAME -- df -h /var/jenkins_home

echo "=== Проверка прав ==="
kubectl exec -n jenkins $POD_NAME -- ls -la /var/jenkins_home/plugins

echo "=== Логи Jenkins ==="
kubectl logs -n jenkins $POD_NAME --tail=50
