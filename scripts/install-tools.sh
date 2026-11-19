#!/usr/bin/env bash
set -Eeuo pipefail

KUBECTL_VERSION="v1.37.2"
KIND_VERSION="v0.30.0"
HELM_VERSION="v4.3.2"

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)
    PLATFORM="amd64"
    AWS_ARCH="x86_64"
    ;;
  aarch64|arm64)
    PLATFORM="arm64"
    AWS_ARCH="aarch64"
    ;;
  *)
    echo "Unsupported architecture: $ARCH"
    exit 1
    ;;
esac

if [[ "$EUID" -eq 0 ]]; then
  SUDO=""
else
  SUDO="sudo"
fi

echo "==> Installing prerequisites..."
$SUDO apt-get update
$SUDO apt-get install -y \
  ca-certificates curl wget unzip openssl jq

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

echo "==> Installing Docker..."
if ! command -v docker >/dev/null 2>&1; then
  curl -fsSL https://get.docker.com -o "$TMP_DIR/get-docker.sh"
  $SUDO sh "$TMP_DIR/get-docker.sh"
fi

$SUDO systemctl enable --now docker

if [[ -n "${SUDO}" ]]; then
  $SUDO usermod -aG docker "${SUDO_USER:-$USER}"
fi

echo "==> Installing AWS CLI v2..."
if ! command -v aws >/dev/null 2>&1; then
  curl -fsSL \
    "https://awscli.amazonaws.com/awscli-exe-linux-${AWS_ARCH}.zip" \
    -o "$TMP_DIR/awscliv2.zip"

  unzip -q "$TMP_DIR/awscliv2.zip" -d "$TMP_DIR"
  $SUDO "$TMP_DIR/aws/install"
fi

echo "==> Installing kubectl ${KUBECTL_VERSION}..."
curl -fsSLo "$TMP_DIR/kubectl" \
  "https://dl.k8s.io/release/${KUBECTL_VERSION}/bin/linux/${PLATFORM}/kubectl"

$SUDO install -o root -g root -m 0755 \
  "$TMP_DIR/kubectl" /usr/local/bin/kubectl

echo "==> Installing Kind ${KIND_VERSION}..."
curl -fsSLo "$TMP_DIR/kind" \
  "https://kind.sigs.k8s.io/dl/${KIND_VERSION}/kind-linux-${PLATFORM}"

$SUDO install -o root -g root -m 0755 \
  "$TMP_DIR/kind" /usr/local/bin/kind

echo "==> Installing Helm ${HELM_VERSION}..."
curl -fsSLo "$TMP_DIR/helm.tar.gz" \
  "https://get.helm.sh/helm-${HELM_VERSION}-linux-${PLATFORM}.tar.gz"

tar -xzf "$TMP_DIR/helm.tar.gz" -C "$TMP_DIR"

$SUDO install -o root -g root -m 0755 \
  "$TMP_DIR/linux-${PLATFORM}/helm" /usr/local/bin/helm

echo
echo "==> Installed tool versions:"
docker --version
aws --version
kubectl version --client
kind version
helm version --short

echo
echo "Installation completed."
echo "IMPORTANT: Log out and log in again for Docker group membership."
echo "Attach an EC2 IAM role with ECR pull permissions before deployment."
