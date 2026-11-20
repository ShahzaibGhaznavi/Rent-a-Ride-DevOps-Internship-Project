#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

AWS_REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="${CLUSTER_NAME:-rent-a-ride}"
NAMESPACE="${NAMESPACE:-rent-a-ride}"
RELEASE_NAME="${RELEASE_NAME:-rent-a-ride}"

FRONTEND_TAG="${FRONTEND_TAG:-task7-3}"
BACKEND_TAG="${BACKEND_TAG:-task9-1}"

for tool in aws kubectl helm; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$tool' is not installed."
    exit 1
  }
done

echo "==> Checking AWS identity..."
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
aws sts get-caller-identity >/dev/null

echo "==> Checking Kubernetes context..."
EXPECTED_CONTEXT="kind-${CLUSTER_NAME}"
CURRENT_CONTEXT="$(kubectl config current-context)"

if [[ "$CURRENT_CONTEXT" != "$EXPECTED_CONTEXT" ]]; then
  echo "ERROR: Wrong Kubernetes context."
  echo "Expected: $EXPECTED_CONTEXT"
  echo "Current:  $CURRENT_CONTEXT"
  echo "Run prepare-helm.sh first to select the correct context."
  exit 1
fi

echo "==> Checking namespace..."
kubectl get namespace "$NAMESPACE" >/dev/null

echo "==> Checking backend secret..."
kubectl get secret backend-secrets -n "$NAMESPACE" >/dev/null

echo "==> Validating Helm chart..."
"$ROOT_DIR/scripts/validate-helm.sh"

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo
echo "==> Deploying application with Helm..."
helm upgrade --install "$RELEASE_NAME" "$ROOT_DIR/helm/rent-a-ride" \
  --namespace "$NAMESPACE" \
  --set-string backend.image.repository="${ECR_REGISTRY}/rent-a-ride-backend" \
  --set-string backend.image.tag="$BACKEND_TAG" \
  --set-string frontend.image.repository="${ECR_REGISTRY}/rent-a-ride-frontend" \
  --set-string frontend.image.tag="$FRONTEND_TAG" \
  --wait \
  --timeout 5m

echo
echo "==> Helm deployment status..."
helm status "$RELEASE_NAME" -n "$NAMESPACE"

echo
echo "Helm deployment completed."
