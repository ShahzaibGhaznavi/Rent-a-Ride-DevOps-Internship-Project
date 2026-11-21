#!/usr/bin/env bash
set -Eeuo pipefail

APP="rent-a-ride"
NAMESPACE="argocd"

echo "===== GitOps Verification ====="

echo
echo "1. ArgoCD Application"
kubectl get application "$APP" -n "$NAMESPACE"

echo
echo "2. Sync and Health Status"
kubectl get application "$APP" -n "$NAMESPACE" \
  -o jsonpath='Sync: {.status.sync.status}{"\n"}Health: {.status.health.status}{"\n"}Revision: {.status.sync.revision}{"\n"}'

echo
echo "3. Application Resources"
kubectl get pods,svc,ingress,hpa -n rent-a-ride

echo
echo "4. GitOps Test Annotation"
kubectl get ingress rent-a-ride-ingress -n rent-a-ride \
  -o jsonpath='{.metadata.annotations.gitops-test}{"\n"}'

echo
echo "===== GitOps Verification Complete ====="