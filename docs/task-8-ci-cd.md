# Task 8: Automated CI/CD Deployment with Jenkins

## 1. Objective

Implement an automated CI/CD pipeline for the Rent-a-Ride application using Jenkins, Docker, Docker Hub, AWS ECR, and Docker Compose.

The pipeline automates application checkout, Docker image building, image publishing, deployment, and health verification.

## 2. Project Architecture

The deployment consists of three main services:

- Frontend: React application served through Nginx.
- Backend: Node.js and Express API.
- Database: MongoDB 8.0.

### Application Flow

Browser
  |
  v
Nginx Frontend (Port 3001)
  |
  v
Express Backend (Port 3000)
  |
  v
MongoDB (Port 27017)

Nginx forwards `/api/` requests to the backend Docker service.

All services communicate through the Docker network:
`rent-a-ride-network`

MongoDB data is persisted using:
`rent-a-ride_mongodb_data`

## 3. CI/CD Tools

- Jenkins: Pipeline automation.
- GitHub: Source code and webhook integration.
- Docker: Application containerization.
- Docker Hub: Container image registry.
- AWS ECR: Private container image registry.
- Docker Compose: Multi-container deployment.
- AWS EC2: Deployment environment.

## 4. Jenkins Pipeline Workflow

The declarative Jenkins pipeline performs the following operations:

1. Checkout source code from GitHub.
2. Build backend Docker image.
3. Build frontend Docker image.
4. Tag images with the Jenkins build number.
5. Authenticate with Docker Hub and AWS ECR.
6. Push backend and frontend images to Docker Hub.
7. Push backend and frontend images to AWS ECR.
8. Remove temporary local build tags.
9. Pull published images for deployment.
10. Deploy services using Docker Compose.
11. Wait for services to become healthy.
12. Perform deployment health checks.
13. Report pipeline success or failure.

### Image Tagging

Images use the following naming convention:

`task7-${BUILD_NUMBER}`

Example:

- `shahzaibazeem/rent-a-ride-backend:task7-5`
- `shahzaibazeem/rent-a-ride-frontend:task7-5`

AWS ECR repositories:

- `rent-a-ride-backend`
- `rent-a-ride-frontend`

## 5. GitHub Integration

Jenkins is configured with GitHub SCM integration.

Configured branch:

`feature/shahzaib-azeem`

GitHub webhook endpoint:

`http://13.233.133.133:8080/github-webhook/`

Webhook events include:

- Push events.
- Pull request events.

The webhook endpoint successfully received GitHub events. Push events have triggered Jenkins builds.

Note: A successful webhook HTTP 200 response confirms delivery to the endpoint. It does not independently confirm that a Jenkins job was triggered. The Jenkins job is configured to monitor the feature branch, so PR merge events targeting `dev` are not automatically equivalent to a feature-branch build.

## 6. Docker Compose Deployment

The deployment uses three services:

| Service | Container | Port |
|---|---|---|
| Frontend | rent-a-ride-frontend | 3001:8080 |
| Backend | rent-a-ride-backend | 3000:3000 |
| MongoDB | rent-a-ride-mongodb | 27018:27017 |

The backend connects to MongoDB using the internal Docker service address:

`mongodb://mongodb:27017/rent_a_ride`

Service health checks are configured in Docker Compose.

The MongoDB named volume preserves database data across container recreation.

## 7. Environment Variables and Credentials

Sensitive environment variables are not committed to GitHub.

The backend environment file is stored securely on EC2:

`/etc/rent-a-ride/.env`

File access is restricted to the appropriate system users and Jenkins group.

Jenkins credentials are managed through Jenkins Credentials:

- `dockerhub-rent-a-ride`
- `github-rent-a-ride`

AWS ECR access is provided through the EC2 IAM role:

`RentARide-EC2-ECR-Role`

## 8. Deployment Verification

The following checks were performed on EC2.

### Docker Container Status

Command:

`docker ps`

Verified containers:

- rent-a-ride-frontend
- rent-a-ride-backend
- rent-a-ride-mongodb

All three containers reported healthy status.

### Frontend Health Check

Command:

`curl -I http://localhost:3001`

Result:

`HTTP 200 OK`

### Backend API Health Check

Command:

`curl -i http://localhost:3000/api/user/listAllVehicles`

Result:

`HTTP 200 OK`

### Frontend and Backend Integration

Command:

`curl -i http://localhost:3001/api/user/listAllVehicles`

Result:

`HTTP 200 OK`

This confirms that Nginx successfully forwards API requests to the backend and the backend retrieves vehicle records from MongoDB.

### Public API Verification

Command:

`curl http://13.233.133.133:3001/api/user/listAllVehicles`

Result:

`HTTP 200 OK`

Public frontend/API access was verified after allowing inbound TCP port 3001 in the EC2 Security Group.

## 9. Troubleshooting

### Docker Permission Denied

Add the Ubuntu user to the Docker group:

`sudo usermod -aG docker ubuntu`

Reconnect to SSH and verify:

`groups`

### Container Status

`docker ps`

### Container Logs

`docker logs rent-a-ride-backend`

`docker logs rent-a-ride-frontend`

`docker logs rent-a-ride-mongodb`

### Docker Compose Status

`docker compose ps`

### Backend API

`curl http://localhost:3000/api/user/listAllVehicles`

### Frontend API Proxy

`curl http://localhost:3001/api/user/listAllVehicles`

### Public Access Timeout

Check the EC2 Security Group inbound rules and confirm that TCP port 3001 is allowed.

## 10. Important Data Protection

- Never commit `.env` files or credentials.
- Do not delete the MongoDB persistent volume during normal deployments.
- Avoid `docker compose down -v` because it deletes named volumes.
- Keep AWS access restricted to the required permissions.
- Remove unused AWS resources after completing the lab to avoid unnecessary charges.

## 11. Result

The Rent-a-Ride CI/CD deployment was implemented using Jenkins and Docker Compose.

The frontend, backend, and MongoDB containers were verified as healthy. Backend API requests were successfully tested directly and through the Nginx frontend proxy. Public API access returned HTTP 200.

The pipeline publishes application images to Docker Hub and AWS ECR and deploys the application on AWS EC2.

