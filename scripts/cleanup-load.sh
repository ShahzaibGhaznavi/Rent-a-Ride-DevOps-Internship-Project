#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="rent-a-ride"

echo "==> Finding backend pods..."

BACKEND_PODS="$(kubectl get pods -n "$NAMESPACE" \
  -o name | grep '^pod/backend-' || true)"

if [[ -z "$BACKEND_PODS" ]]; then
  echo "No backend pods found."
  exit 0
fi

while IFS= read -r POD; do
  [[ -z "$POD" ]] && continue

  echo "Stopping CPU load processes in $POD..."

  kubectl exec -n "$NAMESPACE" "$POD" -- \
    sh -c 'pkill yes 2>/dev/null || true' || true
done <<< "$BACKEND_PODS"

echo
echo "==> Current backend resource usage:"
kubectl top pods -n "$NAMESPACE" | grep backend || true

echo "CPU load cleanup completed."
