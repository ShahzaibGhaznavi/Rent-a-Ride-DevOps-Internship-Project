#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-rent-a-ride}"
RELEASE_NAME="${RELEASE_NAME:-rent-a-ride}"

for tool in helm kubectl; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$tool' is not installed."
    exit 1
  }
done

echo "==> Checking Helm release..."
helm status "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "==> Displaying Helm revision history..."
helm history "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "==> Checking previous revision..."
CURRENT_REVISION="$(helm history "$RELEASE_NAME" \
  --namespace "$NAMESPACE" \
  --max 1 \
  --output json | python3 -c 'import json,sys; print(json.load(sys.stdin)[0]["revision"])')"

if [[ "$CURRENT_REVISION" -le 1 ]]; then
  echo "ERROR: No previous Helm revision is available for rollback."
  exit 1
fi

PREVIOUS_REVISION=$((CURRENT_REVISION - 1))

echo
echo "==> Rolling back to revision $PREVIOUS_REVISION..."
helm rollback "$RELEASE_NAME" "$PREVIOUS_REVISION" \
  --namespace "$NAMESPACE" \
  --wait \
  --timeout 5m

echo
echo "==> Checking application readiness..."
kubectl rollout status deployment/backend \
  --namespace "$NAMESPACE" --timeout=180s

kubectl rollout status deployment/frontend \
  --namespace "$NAMESPACE" --timeout=180s

kubectl rollout status statefulset/mongodb \
  --namespace "$NAMESPACE" --timeout=180s

echo
echo "==> Final Helm release status..."
helm status "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "Rollback and readiness checks completed."
