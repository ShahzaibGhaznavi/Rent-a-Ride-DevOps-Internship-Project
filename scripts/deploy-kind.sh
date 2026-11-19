#!/usr/bin/env bash
set -Eeuo pipefail

# Rent-a-Ride Task 12 deployment automation

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

AWS_REGION="ap-south-1"
AWS_ACCOUNT_ID="332730082659"
CLUSTER_NAME="rent-a-ride"
NAMESPACE="rent-a-ride"

FRONTEND_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/rent-a-ride-frontend:task7-3"
BACKEND_IMAGE="${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/rent-a-ride-backend:task9-1"

echo "==> Checking required tools..."
for tool in aws docker kubectl kind helm; do
  command -v "$tool" >/dev/null 2>&1 || {
    echo "ERROR: $tool is not installed."
    exit 1
  }
done

echo "==> Checking AWS credentials..."
aws sts get-caller-identity >/dev/null

echo "==> Logging in to Amazon ECR..."
aws ecr get-login-password --region "$AWS_REGION" |
  docker login --username AWS --password-stdin \
  "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"

echo "==> Pulling application images..."
docker pull "$FRONTEND_IMAGE"
docker pull "$BACKEND_IMAGE"

echo "==> Creating Kind cluster if it does not exist..."
if ! kind get clusters | grep -qx "$CLUSTER_NAME"; then
  kind create cluster \
    --name "$CLUSTER_NAME" \
    --config kind-config.yaml \
    --wait 120s
else
  echo "Kind cluster already exists."
fi

echo "==> Loading images into Kind..."
kind load docker-image "$FRONTEND_IMAGE" --name "$CLUSTER_NAME"
kind load docker-image "$BACKEND_IMAGE" --name "$CLUSTER_NAME"

echo "==> Creating namespace..."
kubectl apply -f k8s/namespace.yaml

echo "==> Creating backend secret if it does not exist..."
if ! kubectl get secret backend-secrets -n "$NAMESPACE" >/dev/null 2>&1; then
  ACCESS_TOKEN="$(openssl rand -hex 32)"
  REFRESH_TOKEN="$(openssl rand -hex 32)"

  kubectl create secret generic backend-secrets \
    --namespace="$NAMESPACE" \
    --from-literal=ACCESS_TOKEN="$ACCESS_TOKEN" \
    --from-literal=REFRESH_TOKEN="$REFRESH_TOKEN"

  unset ACCESS_TOKEN REFRESH_TOKEN
else
  echo "Backend secret already exists; keeping existing values."
fi

echo "==> Deploying MongoDB..."
kubectl apply -f k8s/mongodb-init-configmap.yaml
kubectl apply -f k8s/mongodb.yaml
kubectl wait --for=condition=Ready pod/mongodb-0 \
  -n "$NAMESPACE" --timeout=180s

echo "==> Deploying Backend and Frontend..."
kubectl apply -f k8s/backend.yaml
kubectl apply -f k8s/frontend.yaml

kubectl rollout status deployment/backend \
  -n "$NAMESPACE" --timeout=180s
kubectl rollout status deployment/frontend \
  -n "$NAMESPACE" --timeout=180s

echo "==> Installing Metrics Server..."
kubectl apply -f \
  https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

kubectl patch deployment metrics-server \
  -n kube-system \
  --type=strategic \
  --patch-file=k8s/metrics-server-patch.yaml

kubectl rollout status deployment/metrics-server \
  -n kube-system --timeout=180s

echo "==> Deploying HPA..."
kubectl apply -f k8s/backend-hpa.yaml

echo "==> Installing Traefik..."
helm repo add traefik https://traefik.github.io/charts
helm repo update

helm upgrade --install traefik traefik/traefik \
  --namespace traefik \
  --create-namespace \
  -f k8s/traefik-values.yaml \
  --wait \
  --timeout 180s

echo "==> Applying Ingress..."
kubectl apply -f k8s/ingress.yaml

echo "==> Waiting for Traefik..."
kubectl rollout status daemonset/traefik \
  -n traefik --timeout=180s

echo
echo "==> Deployment completed!"
echo
kubectl get pods -n "$NAMESPACE"
kubectl get services -n "$NAMESPACE"
kubectl get hpa -n "$NAMESPACE"
kubectl get ingress -n "$NAMESPACE"

echo
echo "Application URL: http://$(curl -s https://checkip.amazonaws.com)"
