#!/usr/bin/env bash

set -u

section() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

section "TASK 14 DIAGNOSTICS"

section "ArgoCD Application Details"
kubectl describe application rent-a-ride -n argocd

section "Image Updater Details"
kubectl describe imageupdater rent-a-ride-updater -n argocd

section "Image Updater Logs"
kubectl logs deployment/argocd-image-updater-controller \
    -n argocd --tail=50

section "Application Pod Details"
kubectl describe pods -n rent-a-ride

section "Ingress Details"
kubectl describe ingress rent-a-ride-ingress -n rent-a-ride

section "Traefik Logs"
kubectl logs -n traefik -l app.kubernetes.io/name=traefik \
    --tail=50

section "Recent Kubernetes Events"
kubectl get events -n rent-a-ride \
    --sort-by='.lastTimestamp'

section "DIAGNOSTICS COMPLETE"