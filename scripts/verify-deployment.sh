#!/usr/bin/env bash
set -Eeuo pipefail

NAMESPACE="rent-a-ride"

echo "==> Checking Kubernetes nodes..."
kubectl get nodes

echo
echo "==> Checking application pods..."
kubectl get pods -n "$NAMESPACE" -o wide

echo
echo "==> Checking services..."
kubectl get services -n "$NAMESPACE"

echo
echo "==> Checking persistent volumes..."
kubectl get pvc -n "$NAMESPACE"

echo
echo "==> Checking HPA..."
kubectl get hpa -n "$NAMESPACE"

echo
echo "==> Checking Ingress..."
kubectl get ingress -n "$NAMESPACE"

echo
echo "==> Checking Traefik..."
kubectl get pods -n traefik

echo
echo "==> Checking resource metrics..."
kubectl top nodes
kubectl top pods -n "$NAMESPACE"

echo
echo "==> Checking application HTTP endpoints..."

curl -fsS -o /dev/null -w 'Frontend: HTTP %{http_code}\n' \
  http://localhost/

curl -fsS -o /dev/null -w 'Health: HTTP %{http_code}\n' \
  http://localhost/health

curl -fsS -o /dev/null -w 'Backend API: HTTP %{http_code}\n' \
  http://localhost/api/user/listAllVehicles

echo
echo "All deployment verification checks passed."
