#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# Reusable GitOps Cleanup Script
# ==========================================

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
APP_NAME="${1:-}"

echo "=========================================="
echo "          GitOps Cleanup"
echo "=========================================="

if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

if [[ -z "$APP_NAME" ]]; then
    echo "Usage: $0 <application-name>"
    exit 1
fi

if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: Namespace '$NAMESPACE' not found."
    exit 1
fi

if ! kubectl get application "$APP_NAME" \
    -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: Application '$APP_NAME' not found."
    exit 1
fi

echo
echo "WARNING: This will delete the ArgoCD Application:"
echo "Application: $APP_NAME"
echo "Namespace:   $NAMESPACE"
echo
echo "It will NOT uninstall ArgoCD or delete the namespace."

read -r -p "Are you sure? Type DELETE to continue: " CONFIRM

if [[ "$CONFIRM" != "DELETE" ]]; then
    echo "Cleanup cancelled."
    exit 0
fi

kubectl delete application "$APP_NAME" \
    -n "$NAMESPACE" \
    --wait=true

echo
echo "ArgoCD Application '$APP_NAME' deleted."
echo "Check remaining resources manually before deleting anything else."