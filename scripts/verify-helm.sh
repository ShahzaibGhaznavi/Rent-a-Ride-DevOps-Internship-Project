#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="${NAMESPACE:-rent-a-ride}"
RELEASE_NAME="${RELEASE_NAME:-rent-a-ride}"
APP_BASE_URL="${APP_BASE_URL:-http://localhost}"

for tool in kubectl helm curl; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$tool' is not installed."
    exit 1
  }
done

echo "==> Checking Helm release..."
helm status "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "==> Checking Kubernetes nodes..."
kubectl get nodes

echo
echo "==> Checking application rollout readiness..."
kubectl rollout status deployment/backend \
  --namespace "$NAMESPACE" --timeout=180s

kubectl rollout status deployment/frontend \
  --namespace "$NAMESPACE" --timeout=180s

kubectl rollout status statefulset/mongodb \
  --namespace "$NAMESPACE" --timeout=180s

echo
echo "==> Checking application workloads..."
kubectl get deployments,statefulsets,pods \
  --namespace "$NAMESPACE" -o wide

echo
echo "==> Checking services..."
kubectl get services --namespace "$NAMESPACE"

echo
echo "==> Checking persistent volume claims..."
kubectl get pvc --namespace "$NAMESPACE"

echo
echo "==> Checking HPA..."
kubectl get hpa --namespace "$NAMESPACE"

echo
echo "==> Checking Ingress..."
kubectl get ingress --namespace "$NAMESPACE"

echo
echo "==> Checking Traefik rollout readiness..."
kubectl rollout status daemonset/traefik \
  --namespace traefik --timeout=180s

kubectl get pods --namespace traefik

echo
echo "==> Checking resource metrics..."
kubectl top nodes
kubectl top pods --namespace "$NAMESPACE"

echo
echo "==> Checking frontend endpoint..."
curl -fsS -o /dev/null \
  -w 'Frontend: HTTP %{http_code}\n' \
  "$APP_BASE_URL/"

echo
echo "==> Checking backend health endpoint..."
curl -fsS -o /dev/null \
  -w 'Backend health: HTTP %{http_code}\n' \
  "$APP_BASE_URL/health"

echo
echo "All Helm deployment verification checks passed."
