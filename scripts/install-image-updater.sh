#!/usr/bin/env bash

set -Eeuo pipefail

# ==========================================
# Reusable ArgoCD Image Updater Installation
# ==========================================

NAMESPACE="${ARGOCD_NAMESPACE:-argocd}"
IMAGE_UPDATER_VERSION="${IMAGE_UPDATER_VERSION:-v1.5.0}"

MANIFEST="https://raw.githubusercontent.com/argoproj-labs/argocd-image-updater/${IMAGE_UPDATER_VERSION}/config/install.yaml"

echo "=========================================="
echo " ArgoCD Image Updater Installation"
echo "=========================================="

# Check kubectl
if ! command -v kubectl >/dev/null 2>&1; then
    echo "ERROR: kubectl is not installed."
    exit 1
fi

# Check ArgoCD namespace
if ! kubectl get namespace "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: ArgoCD namespace '$NAMESPACE' not found."
    echo "Install ArgoCD before installing Image Updater."
    exit 1
fi

# Check ArgoCD server
if ! kubectl get deployment argocd-server \
    -n "$NAMESPACE" >/dev/null 2>&1; then
    echo "ERROR: ArgoCD server deployment not found."
    exit 1
fi

echo "ArgoCD detected in namespace: $NAMESPACE"

# Install Image Updater
echo "Installing Image Updater: $IMAGE_UPDATER_VERSION"

kubectl apply -n "$NAMESPACE" -f "$MANIFEST"

# Wait for controller
echo "Waiting for Image Updater deployment..."

kubectl rollout status \
    deployment/argocd-image-updater-controller \
    -n "$NAMESPACE" \
    --timeout=600s

echo
echo "=========================================="
echo " Installation Verification"
echo "=========================================="

kubectl get deployments -n "$NAMESPACE"
kubectl get pods -n "$NAMESPACE"

echo
echo "Image Updater installation completed."

echo
echo "NOTE:"
echo "Configure registry credentials, ImageUpdater resources,"
echo "image policies and Git write-back separately."