# Task 13: Helm Installation and Application Deployment

## Overview
Deployed Rent-a-Ride on Kubernetes Kind using Helm charts and configurable values.

## Technology Stack
- Kubernetes (Kind)
- Helm v4
- Docker and AWS ECR
- Traefik Ingress Controller
- Metrics Server
- MongoDB 8.0

## Helm Chart
Chart location: helm/rent-a-ride/

Templates include MongoDB, Backend, Frontend, Ingress and Backend HPA.

## Deployment
1. Created Kind cluster using kind-config.yaml.
2. Installed Traefik using Helm.
3. Installed and configured Metrics Server.
4. Pulled frontend, backend and MongoDB images.
5. Loaded images into Kind.
6. Created namespace rent-a-ride and backend-secrets.
7. Validated chart using helm lint and helm template.
8. Installed application using helm upgrade --install.

## Configuration
values.yaml parameterizes images, tags, replicas, ports, resource limits, MongoDB storage, HPA and Ingress routes.

## Architecture
- Frontend: NodePort Service
- Backend: ClusterIP Service
- MongoDB: StatefulSet with 2Gi PVC
- Ingress: Traefik
- HPA: Backend, minimum 1 and maximum 3 replicas, CPU target 70 percent

## Verification Results
- Frontend Pod: Running
- Backend Pod: Running
- MongoDB Pod: Running
- MongoDB PVC: Bound (2Gi)
- Ingress: Configured
- HPA: Active, CPU usage 2 percent
- Frontend endpoint: HTTP 200
- Backend health endpoint: HTTP 200

## Ingress Testing
curl http://localhost/
curl http://localhost/health

## Troubleshooting
MongoDB image import through kind load docker-image failed. Resolved by importing the Docker archive directly into Kind containerd using docker save and ctr images import.

Metrics Server was configured with --kubelet-insecure-tls for the local Kind environment.

## Cleanup
helm uninstall rent-a-ride -n rent-a-ride
kind delete cluster --name rent-a-ride

## Conclusion
Successfully deployed Rent-a-Ride using Helm with configurable templates, persistent MongoDB storage, Traefik Ingress and backend autoscaling. Verified frontend and backend access through Ingress.
