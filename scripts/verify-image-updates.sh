#!/usr/bin/env bash
set -Eeuo pipefail

echo "===== Image Updater Verification ====="

echo
echo "1. Image Updater Resource"
kubectl get imageupdater rent-a-ride-updater -n argocd

echo
echo "2. Image Updater Pods"
kubectl get pods -n argocd

echo
echo "3. Configured Image Tags"
grep -nE 'tag:|image:' helm/rent-a-ride/values.yaml

echo
echo "4. Recent Image Updater Logs"
kubectl logs deployment/argocd-image-updater-controller \
  -n argocd --tail=30

echo
echo "5. Git Changes"
git status --short
git log -5 --oneline

echo
echo "===== Image Updater Verification Complete ====="
