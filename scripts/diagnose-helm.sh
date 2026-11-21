#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-rent-a-ride}"
RELEASE_NAME="${RELEASE_NAME:-rent-a-ride}"
OUTPUT_DIR="${OUTPUT_DIR:-/tmp/rent-a-ride-diagnostics}"

for tool in kubectl helm; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$tool' is not installed."
    exit 1
  }
done

mkdir -p "$OUTPUT_DIR"

echo "==> Checking Helm release..."
helm status "$RELEASE_NAME" --namespace "$NAMESPACE" \
  > "$OUTPUT_DIR/helm-status.txt" 2>&1 || true

helm history "$RELEASE_NAME" --namespace "$NAMESPACE" \
  > "$OUTPUT_DIR/helm-history.txt" 2>&1 || true

echo "==> Collecting application resources..."
kubectl get nodes -o wide \
  > "$OUTPUT_DIR/nodes.txt" 2>&1 || true

kubectl get deployments,statefulsets,pods,services,pvc,hpa,ingress \
  --namespace "$NAMESPACE" -o wide \
  > "$OUTPUT_DIR/application-resources.txt" 2>&1 || true

echo "==> Collecting application events..."
kubectl get events --namespace "$NAMESPACE" \
  --sort-by='.lastTimestamp' \
  > "$OUTPUT_DIR/application-events.txt" 2>&1 || true

echo "==> Collecting application descriptions..."
for RESOURCE in deployment/backend deployment/frontend statefulset/mongodb; do
  FILE_NAME="${RESOURCE//\//-}.txt"

  kubectl describe "$RESOURCE" \
    --namespace "$NAMESPACE" \
    > "$OUTPUT_DIR/$FILE_NAME" 2>&1 || true
done

echo "==> Collecting application container logs..."
for APP in backend frontend; do
  kubectl logs "deployment/$APP" \
    --namespace "$NAMESPACE" \
    --all-containers=true \
    --tail=200 \
    > "$OUTPUT_DIR/$APP-logs.txt" 2>&1 || true
done

kubectl logs statefulset/mongodb \
  --namespace "$NAMESPACE" \
  --all-containers=true \
  --tail=200 \
  > "$OUTPUT_DIR/mongodb-logs.txt" 2>&1 || true

echo "==> Collecting Traefik resources and logs..."
kubectl get pods --namespace traefik -o wide \
  > "$OUTPUT_DIR/traefik-pods.txt" 2>&1 || true

kubectl get events --namespace traefik \
  --sort-by='.lastTimestamp' \
  > "$OUTPUT_DIR/traefik-events.txt" 2>&1 || true

kubectl logs daemonset/traefik --namespace traefik \
  --all-containers=true --tail=200 \
  > "$OUTPUT_DIR/traefik-logs.txt" 2>&1 || true

echo
echo "Diagnostics collection completed."
echo "Output directory: $OUTPUT_DIR"
echo "Review the generated files for deployment errors."
