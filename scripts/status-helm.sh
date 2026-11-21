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

echo "========== HELM RELEASE STATUS =========="
helm status "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "========== HELM REVISION HISTORY =========="
helm history "$RELEASE_NAME" --namespace "$NAMESPACE"

echo
echo "========== KUBERNETES NODES =========="
kubectl get nodes -o wide

echo
echo "========== APPLICATION WORKLOADS =========="
kubectl get deployments,statefulsets,pods \
  --namespace "$NAMESPACE" -o wide

echo
echo "========== SERVICES =========="
kubectl get services --namespace "$NAMESPACE"

echo
echo "========== PERSISTENT VOLUME CLAIMS =========="
kubectl get pvc --namespace "$NAMESPACE"

echo
echo "========== HORIZONTAL POD AUTOSCALER =========="
kubectl get hpa --namespace "$NAMESPACE"

echo
echo "========== INGRESS =========="
kubectl get ingress --namespace "$NAMESPACE"

echo
echo "========== TRAEFIK =========="
kubectl get daemonset,pods --namespace traefik -o wide

echo
echo "========== RESOURCE METRICS =========="
kubectl top nodes
kubectl top pods --namespace "$NAMESPACE"

echo
echo "Status report completed."
