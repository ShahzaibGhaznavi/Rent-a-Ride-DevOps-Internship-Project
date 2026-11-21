#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# Reusable GitOps Application Setup
# ==========================================

APP_MANIFEST="${1:-}"
NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"

echo "=========================================="
echo "       GitOps Application Setup"
echo "=========================================="

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

if [[ -z "$APP_MANIFEST" ]]; then
    echo "Usage: $0 <argocd-application.yaml>"
    exit 1
fi

if [[ ! -f "$APP_MANIFEST" ]]; then
    echo "ERROR: Application manifest not found: $APP_MANIFEST"
    exit 1
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: Namespace '$NAMESPACE' does not exist."
    echo "Install ArgoCD first."
    exit 1
fi

echo "Applying ArgoCD Application manifest..."
kubectl apply -n "$NAMESPACE" -f "$APP_MANIFEST"

echo
echo "Application status:"
kubectl get applications.argoproj.io -n "$NAMESPACE"

echo
echo "GitOps application setup completed."
echo
echo "Check sync and health using:"
echo "kubectl get applications -n $NAMESPACE"