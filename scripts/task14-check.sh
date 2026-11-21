#!/usr/bin/env bash

set -u

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

section() {
    echo
    echo "========================================"
    echo "$1"
    echo "========================================"
}

check() {
    echo
    echo ">>> $1"
    shift
    "$@" || echo "[WARNING] Check failed: $1"
}

section "TASK 14 - GITOPS HEALTH CHECK"

section "Git Information"
git branch --show-current
git status --short

section "Tool Versions"
helm version --short
kubectl version --client
docker --version
aws --version

section "Kubernetes Cluster"
kubectl config current-context
kubectl get nodes -o wide

section "ArgoCD Application"
kubectl get applications -n argocd

section "Image Updater"
kubectl get imageupdaters -n argocd
kubectl get pods -n argocd

section "Application Workloads"
kubectl get pods,svc,ingress,hpa -n rent-a-ride

section "Traefik"
kubectl get pods,svc -n traefik

section "Current Helm Image Tags"
grep -nE 'repository:|tag:' helm/rent-a-ride/values.yaml

section "Helm Chart Validation"
helm lint helm/rent-a-ride

section "Git Whitespace Validation"
git diff --check

section "CHECK COMPLETE"
echo "Review warnings above, if any."