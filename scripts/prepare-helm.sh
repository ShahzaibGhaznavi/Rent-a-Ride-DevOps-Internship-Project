#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

AWS_REGION="${AWS_REGION:-ap-south-1}"
CLUSTER_NAME="${CLUSTER_NAME:-rent-a-ride}"
NAMESPACE="${NAMESPACE:-rent-a-ride}"

FRONTEND_TAG="${FRONTEND_TAG:-task7-3}"
BACKEND_TAG="${BACKEND_TAG:-task9-1}"
TRAEFIK_CHART_VERSION="3.7.19"

for tool in aws docker kubectl kind helm openssl; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: Required tool '$tool' is not installed."
    exit 1
  }
done

echo "==> Checking AWS credentials..."
AWS_ACCOUNT_ID="${AWS_ACCOUNT_ID:-$(aws sts get-caller-identity --query Account --output text)}"
aws sts get-caller-identity >/dev/null

ECR_REGISTRY="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
FRONTEND_IMAGE="${ECR_REGISTRY}/rent-a-ride-frontend:${FRONTEND_TAG}"
BACKEND_IMAGE="${ECR_REGISTRY}/rent-a-ride-backend:${BACKEND_TAG}"
MONGO_IMAGE="mongo:8.0"

echo "==> Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin "$ECR_REGISTRY"

echo "==> Pulling application images..."
docker pull "$FRONTEND_IMAGE"
docker pull "$BACKEND_IMAGE"
docker pull "$MONGO_IMAGE"

echo "==> Creating Kind cluster if required..."
if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config "$ROOT_DIR/kind-config.yaml" \
    --wait 120s
else
  echo "Kind cluster already exists."
fi

echo "==> Selecting correct Kubernetes context..."
kubectl config use-context "kind-$CLUSTER_NAME"
kubectl cluster-info

echo "==> Loading application images into Kind..."
kind load docker-image "$FRONTEND_IMAGE" --name "$CLUSTER_NAME"
kind load docker-image "$BACKEND_IMAGE" --name "$CLUSTER_NAME"

echo "==> Importing MongoDB image into Kind nodes..."
while IFS= read -r NODE; do
  [[ -z "$NODE" ]] && continue
  docker save "$MONGO_IMAGE" |
    docker exec -i "$NODE" ctr --namespace=k8s.io images import -
done < <(kind get nodes --name "$CLUSTER_NAME")

echo "==> Creating application namespace..."
kubectl apply -f "$ROOT_DIR/k8s/namespace.yaml"

echo "==> Creating backend secret if missing..."
if ! kubectl get secret backend-secrets -n "$NAMESPACE" >/dev/null 2>&1; then
  ACCESS_TOKEN="$(openssl rand -hex 32)"
  REFRESH_TOKEN="$(openssl rand -hex 32)"

  kubectl create secret generic backend-secrets \
    --namespace="$NAMESPACE" \
    --from-literal=ACCESS_TOKEN="$ACCESS_TOKEN" \
    --from-literal=REFRESH_TOKEN="$REFRESH_TOKEN"

  unset ACCESS_TOKEN REFRESH_TOKEN
else
  echo "Existing backend secret will be preserved."
fi

echo "==> Installing Metrics Server..."
kubectl apply -f \
  https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch deployment metrics-server \
  -n kube-system \
  --type=strategic \
  --patch-file="$ROOT_DIR/k8s/metrics-server-patch.yaml"

kubectl rollout status deployment/metrics-server \
  -n kube-system --timeout=180s

echo "==> Installing Traefik..."
helm repo add traefik https://traefik.github.io/charts --force-update
helm repo update

helm upgrade --install traefik traefik/traefik \
  --version "$TRAEFIK_CHART_VERSION" \
  --namespace traefik \
  --create-namespace \
  -f "$ROOT_DIR/k8s/traefik-values.yaml" \
  --wait \
  --timeout 180s

kubectl rollout status daemonset/traefik \
  -n traefik --timeout=180s

echo
echo "Preparation completed. No application Helm release was deployed."
