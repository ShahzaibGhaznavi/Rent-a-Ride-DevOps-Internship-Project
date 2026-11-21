# Task 14: GitOps Deployment using ArgoCD with Helm and Image Updater

## 1. Objective

Implement a GitOps-based deployment workflow for the Rent-a-Ride application using Helm, ArgoCD, Kubernetes, AWS ECR and ArgoCD Image Updater.

The objective is to automate application synchronization and container image updates through Git.

## 2. Environment

| Component | Configuration |
|---|---|
| Cloud | AWS EC2 |
| AWS Region | ap-south-1 |
| Kubernetes | Kind |
| Cluster | rent-a-ride |
| Application Namespace | rent-a-ride |
| ArgoCD Namespace | argocd |
| Traefik Namespace | traefik |
| Package Manager | Helm |
| Git Repository | ShahzaibGhaznavi/Rent-a-Ride-DevOps-Internship-Project |
| Monitored Branch | feature/shahzaib-azeem |
| Helm Chart | helm/rent-a-ride |
| Container Registry | AWS ECR |

## 3. Architecture

\`\`\`text
Developer
   |
   v
GitHub Repository
(feature/shahzaib-azeem)
   |
   +---------------------------+
   |                           |
   v                           v
ArgoCD Application       ArgoCD Image Updater
   |                           |
   |                     AWS ECR Registry
   |                           |
   |                     Detect new image tags
   |                           |
   |                     Update Helm values
   |                           |
   |                     Git write-back
   |                           |
   +-------------+-------------+
                 |
                 v
          Helm Chart
       helm/rent-a-ride
                 |
                 v
          Kubernetes
          rent-a-ride
          /     |     \\
      Backend Frontend MongoDB
                 |
                 v
              Traefik
               Ingress
\`\`\`
## 4. Helm Installation and Verification

Helm was installed on the EC2 environment and its version was verified.

## 5. ArgoCD Installation

ArgoCD was installed in the argocd namespace.

Verification commands:

- kubectl get pods -n argocd
- kubectl get svc -n argocd
- kubectl get applications -n argocd

The ArgoCD dashboard was exposed and accessed for application management.

## 6. GitHub Repository Integration

The GitHub repository was connected to ArgoCD.

- Repository: ShahzaibGhaznavi/Rent-a-Ride-DevOps-Internship-Project
- Branch: feature/shahzaib-azeem
- Application: rent-a-ride
- Chart Path: helm/rent-a-ride

ArgoCD monitors the feature branch for configuration changes.
## 7. ArgoCD Application and Helm Deployment

The ArgoCD Application uses the Helm chart located at helm/rent-a-ride.

Automated synchronization was configured with:

- Automated sync
- Prune enabled
- Self-healing enabled
- Automatic namespace creation

The application resources are deployed in the rent-a-ride namespace.

Verification commands:

- kubectl get applications -n argocd
- kubectl get all -n rent-a-ride
- kubectl get ingress -n rent-a-ride
- kubectl get hpa -n rent-a-ride

Note: ArgoCD renders Helm charts and manages the resulting Kubernetes resources. A Helm CLI release record is not required for an ArgoCD-managed application.

## 8. GitOps Change Detection Test

A test annotation was added to the Kubernetes Ingress configuration and committed to the monitored Git branch.

Commit:

94e76bf Add ArgoCD GitOps and image updater configuration

ArgoCD automatically detected the new Git revision and synchronized the application.

Verified revision:

94e76bf282475bea16b3ec5fc93739a32dbd124c

The annotation gitops-test: task14-verified was confirmed in the deployed Ingress resource.

This verified Git-based change detection and automatic synchronization.## 9. ArgoCD Image Updater Installation

ArgoCD Image Updater was installed in the argocd namespace.

Version: 1.5.0

Verification:

- kubectl get pods -n argocd
- kubectl get imageupdaters -n argocd

The ImageUpdater resource was configured for the Rent-a-Ride application.

## 10. AWS ECR Integration and Image Update Policy

AWS ECR was configured as the container image registry.

Backend repository:

332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-backend

Frontend repository:

332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-frontend

Image Updater configuration includes:

- ECR registry integration
- Newest-build update strategy
- Tag filtering using a regular expression
- Helm values image repository and tag updates
- Git write-back using the configured Git credentials
- Monitored branch: feature/shahzaib-azeem

The updater writes image tag changes to:

helm/rent-a-ride/values.yaml

No credentials or secrets are included in this documentation.## 11. Automatic Image Update Verification

ArgoCD Image Updater successfully detected newer image tags in AWS ECR and updated the Helm values file through Git write-back.

### Backend Image Update

- Previous tag: task9-1
- Updated tag: task14-1
- Git commit: 716c4f919b050c819c8af88b49212777a47a0766

### Frontend Image Update

- Previous tag: task7-3
- Updated tag: task7-6
- Git commit: e49208babf4a6060cc7854cfe90e4bf2c3219c0b

Both commits were created automatically by:

argocd-image-updater <noreply@argoproj.io>

The commits updated:

helm/rent-a-ride/values.yaml

The current Helm values were verified:

- Backend image tag: task14-1
- Frontend image tag: task7-6

This confirmed automatic image detection, Helm values write-back and Git-based deployment updates.## 12. Kubernetes Workload Verification

The following application workloads were verified in the rent-a-ride namespace:

| Workload | Status |
|---|---|
| Backend | 1/1 Running |
| Frontend | 1/1 Running |
| MongoDB | 1/1 Running |

MongoDB had one historical restart during the verification.

The backend Horizontal Pod Autoscaler was also verified.

- Minimum replicas: 1
- Maximum replicas: 3
- Target CPU utilization: 70%
- Observed CPU utilization: 2%
- Current replicas: 1

Verification commands:

- kubectl get pods -n rent-a-ride
- kubectl get hpa -n rent-a-ride
- kubectl top pods -n rent-a-ride

## 13. Traefik Ingress and Application Routing

Traefik was deployed as the Kubernetes Ingress Controller.

The application Ingress routes traffic as follows:

- /api and /health to the backend service on port 3000
- / to the frontend service on port 80

Application routing was tested using port forwarding:

kubectl port-forward -n traefik svc/traefik 8082:80

Frontend test:

curl -I http://127.0.0.1:8082/

Result: HTTP 200 OK

Backend health test:

curl -i http://127.0.0.1:8082/health

Result: HTTP 200 OK

The backend returned:

{"status":"healthy","database":"connected"}

Note: Application routing was verified locally through port forwarding. Public external Ingress access was not verified.## 14. Troubleshooting and Findings

- ArgoCD synchronization was successful.
- Application health remained Progressing because of the Ingress resource status. The likely limitation is the Kind cluster's ClusterIP-based Traefik service without an external LoadBalancer address.
- Application routing worked through local port forwarding.
- HPA metrics became available after workload readiness.
- An empty Helm CLI release list does not indicate deployment failure because ArgoCD manages the rendered Helm resources.

## 15. Useful Verification Commands

- kubectl get applications -n argocd
- kubectl get pods -n argocd
- kubectl get pods -n rent-a-ride
- kubectl get ingress -n rent-a-ride
- kubectl get hpa -n rent-a-ride
- kubectl get imageupdaters -n argocd
- helm lint helm/rent-a-ride

## 16. Task Outcome

- Helm installation and chart validation
- ArgoCD installation and dashboard access
- GitHub repository and branch integration
- Helm-based Kubernetes deployment
- Automated GitOps synchronization
- AWS ECR integration
- ArgoCD Image Updater configuration
- Automatic image tag detection
- Helm values Git write-back
- Kubernetes workload and routing verification

## 17. Git Workflow

All Task 14 changes are maintained on feature/shahzaib-azeem.

The intended pull request target is dev.

The dev branch has not been merged or modified as part of this documentation work.