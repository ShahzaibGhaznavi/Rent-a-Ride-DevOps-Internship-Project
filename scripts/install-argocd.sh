#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# Reusable ArgoCD Installation Script
# ==========================================

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
ARGOCD_VERSION="${ARGOCD_VERSION:-v3.6.2}"
INSTALL_MANIFEST="https://raw.githubusercontent.com/argoproj/argo-cd/${ARGOCD_VERSION}/manifests/install.yaml"

echo "=========================================="
echo "       ArgoCD Installation"
echo "=========================================="

# Check kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

# Check Kubernetes connection
if ! kubectl cluster-info >/dev/null 2>&1; then
    echo "ERROR: Cannot connect to Kubernetes cluster."
    exit 1
fi

echo "Kubernetes connection verified."

# Create namespace
echo "Creating namespace: ${NAMESPACE}"
kubectl create namespace "$NAMESPACE" \
    --dry-run=client -o yaml | kubectl apply -f -

# Install ArgoCD
echo "Installing ArgoCD version: ${ARGOCD_VERSION}"

kubectl apply -n "$NAMESPACE" -f "$INSTALL_MANIFEST"

# Wait for deployments
echo "Waiting for ArgoCD deployments..."

kubectl wait \
    --for=condition=Available \
    deployment \
    --all \
    -n "$NAMESPACE" \
    --timeout=600s

# Wait for application controller StatefulSet
if kubectl get statefulset argocd-application-controller \
    -n "$NAMESPACE" >/dev/null 2>&1; then

    kubectl rollout status \
        statefulset/argocd-application-controller \
        -n "$NAMESPACE" \
        --timeout=600s
fi

echo
echo "=========================================="
echo "       ArgoCD Installation Status"
echo "=========================================="

kubectl get pods -n "$NAMESPACE"
kubectl get services -n "$NAMESPACE"

echo
echo "ArgoCD installation completed successfully."

echo
echo "To access the ArgoCD dashboard locally, run:"
echo "kubectl port-forward svc/argocd-server -n ${NAMESPACE} 8080:443"

echo
echo "Dashboard: https://localhost:8080"