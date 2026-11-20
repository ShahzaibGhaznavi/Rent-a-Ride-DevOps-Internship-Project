#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHART_DIR="$ROOT_DIR/helm/rent-a-ride"

RELEASE_NAME="${RELEASE_NAME:-rent-a-ride}"
NAMESPACE="${NAMESPACE:-rent-a-ride}"

command -v helm >/dev/null 2>&1 || {
  echo "ERROR: Helm is not installed."
  exit 1
}

echo "==> Validating Helm chart..."
helm lint "$CHART_DIR"

echo
echo "==> Rendering Helm templates..."
helm template "$RELEASE_NAME" "$CHART_DIR" \
  --namespace "$NAMESPACE" \
  > /tmp/rent-a-ride-rendered.yaml

echo "Helm validation and template rendering completed."
