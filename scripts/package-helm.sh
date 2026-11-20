#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHART_DIR="$ROOT_DIR/helm/rent-a-ride"
OUTPUT_DIR="$ROOT_DIR/dist"

command -v helm >/dev/null 2>&1 || {
  echo "ERROR: Helm is not installed."
  exit 1
}

mkdir -p "$OUTPUT_DIR"

echo "==> Validating Helm chart..."
helm lint "$CHART_DIR"

echo
echo "==> Packaging Helm chart..."
helm package "$CHART_DIR" --destination "$OUTPUT_DIR"

echo
echo "==> Generated Helm packages..."
ls -lh "$OUTPUT_DIR"/*.tgz

echo
echo "Helm chart packaging completed."
