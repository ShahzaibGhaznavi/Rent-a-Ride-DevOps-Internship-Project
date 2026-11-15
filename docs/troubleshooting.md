
# Troubleshooting and Setup Notes

This document records setup issues, fixes, and local deployment testing
performed during the Rent-a-Ride DevOps internship project.

## 1. Incorrect backend installation instructions

**Issue:** The original README instructed users to run `npm install` inside
the `backend` directory, but the backend dependencies and scripts are defined
in the root `package.json`.

**Solution:** Run `npm install` from the project root directory.

## 2. Missing environment variable examples

**Issue:** The project requires backend and frontend environment variables,
but example environment files were missing.

**Solution:**
- Added root `.env.example` for backend configuration.
- Added `client/.env.example` for frontend configuration.
- Actual `.env` files must contain valid credentials and must never be committed.

## 3. Razorpay frontend environment variable

**Issue:** The frontend accessed `RAZORPAY_KEY_ID` without the Vite `VITE_`
prefix, so Vite would not expose the variable to browser code.

**Solution:** Updated the frontend reference to
`import.meta.env.VITE_RAZORPAY_KEY_ID`.

Only the public Razorpay Key ID belongs in frontend configuration.
The Razorpay Secret must remain on the backend.

## 4. package-lock.json ignored by Git

**Issue:** `.gitignore` contained entries ignoring `package-lock.json`.

**Solution:** Removed those entries so npm lockfiles can be committed and
dependency versions can be reproduced consistently.

## 5. Safe environment configuration

Never commit real API keys, passwords, database credentials, or secrets.
Use `.env.example` as a template and keep actual `.env` files private.

## 6. Local MongoDB setup

**Issue:** The application requires a MongoDB database connection for
backend operations.

**Solution:**
- Installed MongoDB Community Server locally.
- Started and verified the MongoDB Windows service.
- Configured the local database connection in the root `.env` file.
- Connected using `mongosh` and verified the database with a ping command.

Local database used:

`rent_a_ride`

MongoDB connection:

`mongodb://127.0.0.1:27017/rent_a_ride`

## 7. Backend and frontend environment configuration

**Issue:** The backend and frontend require separate environment
configuration.

**Solution:**
- Created the root `.env` from `.env.example`.
- Created `client/.env` from `client/.env.example`.
- Configured the local MongoDB URI and backend token variables.
- Configured the frontend backend URL as `http://localhost:3000`.
- Kept actual environment files out of Git.

## 8. Starting backend and frontend services

**Issue:** Both application services must be running for local application
testing.

**Solution:**

Start the backend from the project root:

`npm run dev`

Start the frontend in a separate terminal:

`cd client`

`npm run dev`

Local frontend:

`http://localhost:5173/`

Local backend:

`http://localhost:3000`

Keep both terminal sessions running during testing.

## 9. Empty vehicle and location data

**Issue:** The local MongoDB database initially did not contain the vehicle
and location records needed for complete application testing.

**Solution:**
- Added five sample test vehicle records.
- Added sample location records to the `masterdatas` collection.
- Verified that vehicle listings and pickup/drop-off location dropdowns
  were populated.

These records are local testing data, not production data.

## 10. Vehicle listing and filtering issue

**Issue:** The vehicle listing page did not consistently display all
available vehicles because the Redux filtered vehicle list was not
synchronized with the latest API response.

**Solution:**
- Updated the vehicle listing component to dispatch both `showVehicles`
  and `setFilteredData` after fetching vehicle records.
- Updated the vehicle display logic to handle an empty filtered result
  without falling back to the complete vehicle list.
- Added a `No vehicles found` message for empty results.

## 11. Checkout total calculation

**Issue:** The checkout total calculation used an incorrect JavaScript
expression, which could produce an incorrect total.

**Solution:** Corrected the calculation to:

`price * Days + 50 - discount`

The local test verified a total of ₹1550 for one day at ₹1500 per day
with ₹50 shipping and no discount.

## 12. Checkout loading state

**Issue:** The checkout page could retain a stale loading state and
continue displaying `Processing...`.

**Solution:**
- Reset the page loading state when the checkout page mounts.
- Added loading-state cleanup for payment initialization and modal
  dismissal/failure paths.
- Verified that the checkout button displays `Place Order` when idle.

## 13. Local application connectivity and testing

The following local checks were performed:

- MongoDB ping command returned `ok: 1`.
- Backend vehicle API returned HTTP 200.
- Frontend loaded successfully at `http://localhost:5173/`.
- User registration and login were tested.
- Vehicle listing, details, sorting, and filtering were tested.
- Pickup and drop-off location selection was tested.
- Vehicle search and checkout details were tested.
- Required field validation was checked.
- Checkout total calculation was verified.
- Frontend production build completed successfully using `npm run build`.

## 14. Razorpay payment testing limitation

**Issue:** The local Razorpay Key ID is still a placeholder and is not a
valid Razorpay test key.

**Status:** Actual payment and booking completion through Razorpay have
not been tested.

**Solution / Next step:**
Configure valid Razorpay test credentials before attempting a payment.
Do not commit Razorpay credentials or expose the Razorpay Secret.

## 15. Frontend production build warnings

**Observation:** The Vite production build completed successfully, but
reported unresolved CSS/image asset paths and a large JavaScript chunk.

These warnings did not prevent the build from completing. They remain
documented observations and were not treated as blockers for local
application testing.



## 16. Docker containerization architecture

**Implementation:** Containerized the frontend, backend, and MongoDB using
Docker and Docker Compose.

Services:

- **Frontend:** Multi-stage build using Node.js 26 Alpine and unprivileged Nginx.
- **Backend:** Node.js 26 Alpine multi-stage container running as non-root.
- **MongoDB:** MongoDB 8.0 container.
- **Nginx:** Serves the frontend and proxies `/api/` requests to the backend.

Local endpoints:

| Service | URL / Port |
|---|---|
| Frontend | http://localhost:3001 |
| Backend API | http://localhost:3000 |
| MongoDB host port | 27018 |
| MongoDB container port | 27017 |

## 17. Docker prerequisites and startup

Install Docker Desktop and ensure its Docker Engine is running.

Create the root environment file from the example if it does not
already exist:

`cp .env.example .env`

Configure valid backend credentials and the public frontend Firebase
and Razorpay Key ID values in the environment files.

Build and start all services from the project root:

`docker compose up -d --build`

Check container status:

`docker compose ps`

View service logs:

`docker compose logs -f`

## 18. Docker networking and database connectivity

**Issue:** Containers cannot use `localhost` to communicate with other
services because each container has its own network environment.

**Solution:**

- The backend connects to MongoDB using the Compose service hostname
  `mongodb`.
- The MongoDB connection inside Docker is
  `mongodb://mongodb:27017/rent_a_ride`.
- The frontend Nginx configuration proxies `/api/` requests to
  `http://backend:3000/api/`.
- Docker Compose provides service-to-service networking.

The backend's Docker Compose environment overrides the local MongoDB URI
with the container network URI.

## 19. MongoDB persistent storage and seed data

**Issue:** Database records must remain available when containers are
recreated.

**Solution:**

- Configured the named Docker volume `mongodb_data` at `/data/db`.
- Added `mongo-init/01-seed.js` to initialize a fresh database.
- The seed script inserts five sample vehicles and fifteen masterdata
  records when their respective collections are empty.
- Existing collection records are not overwritten by the seed script.

MongoDB data is persisted independently of the MongoDB container.

**Important:** MongoDB initialization scripts run only when the database
is initialized with an empty data directory. Recreating a container with
an existing named volume does not automatically rerun these scripts.

Do not use `docker compose down -v` for routine cleanup because it removes
the Compose-managed named volume and its database data.

## 20. Frontend Nginx reverse proxy

**Issue:** The frontend browser needs to communicate with the backend
running in a separate container.

**Solution:**

Configured `client/nginx.conf` to:

- Serve the built React application.
- Support client-side routing using `try_files`.
- Forward `/api/` requests to the backend service.
- Preserve the relevant request headers.

The frontend can therefore access backend APIs through the same host
origin:

`http://localhost:3001/api/`

## 21. Docker verification and API testing

Check the status of all containers:

`docker compose ps`

Check MongoDB health:

`docker compose ps mongodb`

Test the backend vehicle API:

`curl -i http://localhost:3000/api/user/listAllVehicles`

Test the frontend Nginx API proxy:

`curl -i http://localhost:3001/api/user/listAllVehicles`

Both API requests returned HTTP 200 during testing.

Verified application behavior:

- Frontend loaded at `http://localhost:3001`.
- Five vehicle images were displayed.
- Booking form location dropdowns displayed options.
- Backend API was accessible directly and through the frontend Nginx proxy.
- Fresh MongoDB initialization inserted five vehicles and fifteen
  masterdata records.
- MongoDB reported a healthy container status.

## 22. Docker troubleshooting commands

Check service logs:

`docker compose logs backend`

`docker compose logs frontend`

`docker compose logs mongodb`

Rebuild and restart services:

`docker compose up -d --build`

Restart a specific service:

`docker compose restart backend`

Check running containers:

`docker compose ps`

Check MongoDB records:

`docker compose exec mongodb mongosh rent_a_ride --quiet --eval 'print("Vehicles: " + db.vehicles.countDocuments()); print("Masterdata: " + db.masterdatas.countDocuments());'`

Stop services without deleting persistent database storage:

`docker compose down`

**Important:** Do not use `docker compose down -v` unless intentional
database-volume deletion has been approved and the data has been backed up.

## 23. Known limitations and observations

- Razorpay payment completion has not been verified because valid
  Razorpay test credentials were not available.
- The frontend production build completes, but reports unresolved
  CSS/image asset references and a large JavaScript bundle warning.
- npm audit reported dependency vulnerabilities during the frontend
  build. They have not been automatically fixed.
- Actual third-party integrations require valid credentials supplied
  through private environment configuration.


## 24. Dedicated Docker Network Configuration (Task 4)

**Requirement:** Frontend, backend, and MongoDB containers must communicate through a dedicated Docker network.

**Implementation:**
- Created a custom Docker bridge network named `rent-a-ride-network`.
- Connected all three Compose services to this network.
- Backend communicates with MongoDB through the Docker service hostname `mongodb` on port `27017`.
- Frontend Nginx forwards API requests to the backend service on port `3000`.

**Network configuration:**

```yaml
networks:
  rent_a_ride_network:
    name: rent-a-ride-network
    driver: bridge
```

**Verification:**

`docker network inspect rent-a-ride-network`

All three containers were confirmed connected to the custom network.

**Security note:** The dedicated bridge network provides isolation from unrelated Docker networks. It does not provide encryption by itself; application authentication and secure credentials are still required.

## 25. Explicit MongoDB Volume Configuration (Task 4)

**Requirement:** Database records must survive container restarts and recreation.

**Implementation:**
- Configured the named volume `rent-a-ride_mongodb_data`.
- Mounted the volume at MongoDB's `/data/db` directory.
- Explicitly assigned the existing volume name in Docker Compose to preserve previously stored database records.

**Volume configuration:**

```yaml
volumes:
  mongodb_data:
    name: rent-a-ride_mongodb_data
```

**Verification:**

`docker volume inspect rent-a-ride_mongodb_data`

The existing volume was successfully reused.

## 26. Docker Network, Application, and Persistence Verification (Task 4)

**Container status:**

`docker compose ps`

- Frontend: Running.
- Backend: Running.
- MongoDB: Running and healthy.

**Network verification:**

`docker network inspect rent-a-ride-network`

Confirmed that frontend, backend, and MongoDB were connected to the custom bridge network.

**Volume verification:**

`docker volume inspect rent-a-ride_mongodb_data`

Confirmed that the existing named MongoDB volume was preserved.

**API connectivity:**

Backend API:

`curl -i http://localhost:3000/api/user/listAllVehicles`

Frontend Nginx proxy:

`curl -i http://localhost:3001/api/user/listAllVehicles`

Both endpoints returned HTTP 200 and the same five vehicle records.

**Database persistence test:**

Before restarting MongoDB, the following collection counts were recorded:

| Collection | Records |
|---|---:|
| vehicles | 5 |
| users | 1 |
| masterdatas | 15 |
| bookings | 0 |

Restarted MongoDB using:

`docker compose restart mongodb`

After the restart, all collection counts remained unchanged:

| Collection | Records |
|---|---:|
| vehicles | 5 |
| users | 1 |
| masterdatas | 15 |
| bookings | 0 |

**Result:** Database persistence was successfully verified after the MongoDB container restart. No database records were deleted.

## 27. Task 4 Troubleshooting and Safe Cleanup

Check custom network connections:

`docker network inspect rent-a-ride-network`

Check persistent volume details:

`docker volume inspect rent-a-ride_mongodb_data`

Check MongoDB collection counts:

`docker exec rent-a-ride-mongodb mongosh rent_a_ride --quiet --eval 'db.getCollectionNames().forEach(c => print(c + ": " + db.getCollection(c).countDocuments()))'`

Restart MongoDB without deleting its volume:

`docker compose restart mongodb`

Stop services while retaining persistent database storage:

`docker compose down`

**Important:** Never use `docker compose down -v` for routine cleanup. It removes Compose-managed volumes and can permanently delete database data.


## 28. Multi-Stage Docker Builds and Non-Root Containers (Task 5)

Task 5 introduced optimized multi-stage Docker builds and non-root application containers.

### Backend Docker Configuration

The backend Dockerfile uses Node.js 26 Alpine with separate dependency and production stages.

- Production dependencies are installed using `npm ci --omit=dev`.
- Application files are copied with `node:node` ownership.
- The application runs using the non-root `node` user.

Verify the backend runtime user:

```bash
docker exec rent-a-ride-backend id


Expected user:

uid=1000(node) gid=1000(node) groups=1000(node)
Frontend Docker Configuration
The frontend uses Node.js 26 Alpine for building the production application and nginxinc/nginx-unprivileged:stable-alpine for serving the generated files.
- Nginx runs as the non-root nginx user.
- Nginx listens on port 8080.
- Docker Compose maps host port 3001 to container port 8080.
Verify the frontend runtime user:
docker exec rent-a-ride-frontend id


Expected user:

uid=101(nginx) gid=101(nginx) groups=101(nginx)
Issue: Frontend Container Fails to Start
Possible cause: Nginx configuration uses port 80 while the unprivileged Nginx image is configured to listen on port 8080.

Solution:

Check client/nginx.conf:
listen 8080;


Check the frontend port mapping in docker-compose.yml:
ports:
  - "3001:8080"


Rebuild and restart:
docker compose build frontend
docker compose up -d frontend
docker compose ps


Issue: Backend Permission Denied
Possible cause: Application files or dependencies are not accessible to the non-root node user.

Solution: Ensure files copied into the production stage use the correct ownership:
COPY --from=dependencies --chown=node:node /app/node_modules ./node_modules
COPY --chown=node:node package*.json ./
COPY --chown=node:node backend/ ./backend/


Also ensure the Dockerfile switches to the non-root user:
USER node


Rebuild the backend:
docker compose build --no-cache backend
docker compose up -d backend


Issue: Docker Image Build Fails
Check Docker Compose configuration:
docker compose config -q


Rebuild application images:
docker compose build --no-cache frontend backend


Start the services:
docker compose up -d


Check container status and logs:
docker compose ps
docker compose logs --tail=100 backend
docker compose logs --tail=100 frontend


Full-Stack HTTP Verification
Check the frontend:
curl -i http://localhost:3001/


Check the backend API:
curl -i http://localhost:3000/api/user/listAllVehicles


Check the frontend Nginx API proxy:
curl -i http://localhost:3001/api/user/listAllVehicles


Expected result: HTTP 200 for all three checks.
Docker Daemon Rootless Mode
Non-root application containers and rootless Docker daemon mode are different configurations.

The backend and frontend application processes were verified to run as non-root users. However, the Docker daemon was not running in rootless mode during this task.

Check Docker security options:
docker info --format '{{json .SecurityOptions}}'


Do not interpret non-root container users as proof that the Docker daemon itself is rootless.

## 29. Publishing and Pulling Images from Registries (Task 5)
The backend and frontend images were published with the task5 tag to Docker Hub, GitHub Container Registry, and AWS ECR.
### Docker Hub
docker pull shahzaibazeem/rent-a-ride-backend:task5
docker pull shahzaibazeem/rent-a-ride-frontend:task5


If authentication is required:
docker login


### GitHub Container Registry (GHCR)
Authenticate using a GitHub Personal Access Token with the required package permissions:
docker login ghcr.io -u ShahzaibGhaznavi


Pull images:
docker pull ghcr.io/shahzaibghaznavi/rent-a-ride-backend:task5
docker pull ghcr.io/shahzaibghaznavi/rent-a-ride-frontend:task5


### AWS Elastic Container Registry (ECR)
Authenticate to the AWS ECR registry:
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 332730082659.dkr.ecr.ap-south-1.amazonaws.com


Pull images:
docker pull 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-backend:task5
docker pull 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-frontend:task5


Issue: Docker Registry Authentication Failed
Docker Hub:
docker logout
docker login


GHCR:

Use a valid GitHub Personal Access Token with read:packages permission for pulling private packages. Use write:packages when publishing images.
docker logout ghcr.io
docker login ghcr.io -u ShahzaibGhaznavi


AWS ECR:

Confirm the AWS identity and region:
aws sts get-caller-identity
aws configure get region


Refresh ECR authentication:
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 332730082659.dkr.ecr.ap-south-1.amazonaws.com


### ECR Image Scan Findings Unavailable
Both ECR repositories were configured with scan-on-push enabled. However, image scan findings were not available when queried during this task.

Do not treat scan-on-push configuration as proof that a completed vulnerability scan or clean scan result was obtained.
### Known Build Warnings
The builds completed successfully, but npm reported dependency vulnerabilities and deprecated packages. The frontend build also reported unresolved asset references and a large JavaScript bundle warning.

Forced dependency upgrades were avoided to reduce the risk of breaking existing application functionality. These warnings remain items for future maintenance.

---

## 30. Docker Compose Orchestration and Container Management (Task 6)

Task 6 covers managing the frontend, backend, and MongoDB services together using Docker Compose, pulling pre-built images, configuring healthchecks, and verifying container recovery.

### Issue 1: Application Images Are Not Available Locally

**Cause:** Task 6 uses pre-built frontend and backend images published on Docker Hub.

**Solution:**

```bash
docker compose pull backend frontend
docker compose up -d
```

### Issue 2: Services Are Not Starting Properly

**Cause:** Backend depends on MongoDB health, while frontend depends on backend health.

**Checks:**

```bash
docker compose ps
docker compose logs mongodb
docker compose logs backend
docker compose logs frontend
```

Wait until the required dependency services report healthy.

### Issue 3: Backend Cannot Connect to MongoDB

**Cause:** Containers must communicate using the Docker Compose service hostname instead of `localhost`.

**Correct MongoDB connection URI:**

```text
mongodb://mongodb:27017/rent_a_ride
```

**Checks:**

```bash
docker compose exec backend printenv mongo_uri
docker compose ps
docker compose logs backend
```

Ensure MongoDB is healthy and the backend uses the correct connection URI. Never expose or commit private credentials.

### Issue 4: Frontend or Backend API Is Not Responding

**Checks:**

```bash
curl -i http://localhost:3001/
curl -i http://localhost:3000/api/user/listAllVehicles
curl -i http://localhost:3001/api/user/listAllVehicles
```

Check application logs:

```bash
docker compose logs --tail=100
```

All three endpoints returned HTTP 200 during Task 6 verification. If an endpoint fails, inspect the relevant service logs, container status, and port mappings.

### Issue 5: Frontend Cannot Reach the Backend

**Cause:** Frontend Nginx must forward API requests to the backend service through the Docker Compose network.

**Expected backend service address inside Docker:**

```text
http://backend:3000
```

**Checks:**

```bash
docker compose ps
docker compose logs frontend
docker compose logs backend
docker network inspect rent-a-ride-network
```

Ensure all three services are connected to the expected Docker network.

### Issue 6: Container Keeps Restarting

**Possible causes:** Application errors, incorrect configuration, or unavailable dependencies.

**Checks:**

```bash
docker compose ps
docker compose logs --tail=100 backend
docker inspect --format='Status: {{.State.Status}} | Restart Count: {{.RestartCount}}' rent-a-ride-backend
```

The services use the `unless-stopped` restart policy. Review application logs to identify the actual cause before changing restart configuration.

### Issue 7: Container Healthcheck Reports Unhealthy

**Possible cause:** The configured healthcheck endpoint or a required dependency is not responding successfully.

**Checks:**

```bash
docker compose ps
docker inspect rent-a-ride-backend
docker inspect rent-a-ride-frontend
docker inspect rent-a-ride-mongodb
```

Review healthcheck results and service logs to identify the failing check.

### Issue 8: Stop or Recreate Containers Without Losing Database Data

**Solution:**

Stop the application stack:

```bash
docker compose down
```

Start it again:

```bash
docker compose up -d
```

The named MongoDB volume `rent-a-ride_mongodb_data` is retained when `docker compose down` runs without the `-v` option.

**Important:** Never use `docker compose down -v` for routine cleanup because it removes the Compose-managed MongoDB volume and its stored data.

### Useful Task 6 Commands

Validate the Compose configuration:

```bash
docker compose config -q
```

Pull application images:

```bash
docker compose pull backend frontend
```

Start services in detached mode:

```bash
docker compose up -d
```

Check service status:

```bash
docker compose ps
```

View recent logs:

```bash
docker compose logs --tail=50
```

Follow backend logs:

```bash
docker compose logs -f backend
```

Inspect the MongoDB volume:

```bash
docker volume inspect rent-a-ride_mongodb_data
```

Inspect the application network:

```bash
docker network inspect rent-a-ride-network
```

**Security and Data Protection Note:** Keep actual environment files and credentials out of Git. Avoid deleting named Docker volumes unless database data removal is explicitly intended.
## 31. Jenkins CI/CD Pipeline and Runtime Verification (Task 7)

### Jenkins Environment
- OS: Ubuntu 26.04 LTS on AWS EC2
- Jenkins: LTS
- Java: 21
- Docker: 29.1.3
- Docker Compose: 2.40.3
- AWS Region: ap-south-1

### CI/CD Pipeline
1. Checkout source code from the GitHub feature branch.
2. Build backend and frontend Docker images.
3. Push images to Docker Hub.
4. Push images to AWS ECR.

Published images:
- `shahzaibazeem/rent-a-ride-backend:task7-3`
- `shahzaibazeem/rent-a-ride-frontend:task7-3`
- `332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-backend:task7-3`
- `332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-frontend:task7-3`

### GitHub Webhook Verification
- GitHub push webhook configured with Jenkins.
- Webhook ping returned HTTP 200.
- GitHub push automatically triggered Jenkins Build #3.
- Jenkins Build #3 completed successfully.

### Docker Compose Runtime Testing
Three services were started on EC2:
- MongoDB 8.0
- Rent-a-Ride backend
- Rent-a-Ride frontend

All three containers reached a healthy state.

Frontend test: `http://localhost:3001/` returned HTTP 200.

Backend API through the frontend NGINX proxy:
`http://localhost:3001/api/user/listAllVehicles` returned HTTP 200.

### Issues and Fixes
- Installed Docker Compose v2 because it was initially unavailable.
- Created `.env` from `.env.example` and restricted its permissions.
- Updated Compose image references from Task 5 tags to Task 7 tags.
- Used `sudo` for Docker commands where required.

### Known Limitations
- Real Firebase, Razorpay, email and Cloudinary credentials still need configuration.
- HTTP 200 confirms basic frontend and API availability, not complete booking, authentication or payment workflows.
- Jenkins builds and publishes images; production deployment is not automated.

### Useful Verification Commands
- `sudo docker compose ps`
- `sudo docker images`
- `sudo docker compose logs --tail=50`
- `sudo systemctl status jenkins`

---

## 32. Task 8: Automated CI/CD Deployment with Jenkins

### Objective

Implement an automated CI/CD pipeline for the Rent-a-Ride application using Jenkins, Docker, Docker Hub, AWS ECR, and Docker Compose.

The pipeline automates source code checkout, Docker image building, image publishing, deployment, and health verification.

### Project Architecture

The application consists of three services:

- Frontend: React application served through Nginx.
- Backend: Node.js and Express API.
- Database: MongoDB 8.0.

Application flow:

Browser → Nginx Frontend (Port 3001) → Express Backend (Port 3000) → MongoDB (Port 27017).

Nginx forwards `/api/` requests to the backend Docker service.

Docker network: `rent-a-ride-network`

MongoDB persistent volume: `rent-a-ride_mongodb_data`

### CI/CD Tools

- Jenkins: Pipeline automation.
- GitHub: Source code and webhook integration.
- Docker: Application containerization.
- Docker Hub: Container image registry.
- AWS ECR: Private container image registry.
- Docker Compose: Multi-container deployment.
- AWS EC2: Deployment environment.

### Jenkins Pipeline Workflow

The declarative Jenkins pipeline performs these operations:

1. Checkout source code from GitHub.
2. Build backend Docker image.
3. Build frontend Docker image.
4. Tag images using the Jenkins build number.
5. Authenticate with Docker Hub and AWS ECR.
6. Push backend and frontend images to Docker Hub.
7. Push backend and frontend images to AWS ECR.
8. Remove temporary local build tags.
9. Pull published images for deployment.
10. Deploy services using Docker Compose.
11. Wait for services to become healthy.
12. Perform deployment health checks.
13. Report pipeline success or failure.

Image tagging convention:

`task7-${BUILD_NUMBER}`

Example:

- `shahzaibazeem/rent-a-ride-backend:task7-5`
- `shahzaibazeem/rent-a-ride-frontend:task7-5`

AWS ECR repositories:

- `rent-a-ride-backend`
- `rent-a-ride-frontend`

### GitHub Webhook Integration

Configured branch:

`feature/shahzaib-azeem`

Jenkins webhook endpoint:

`http://13.233.133.133:8080/github-webhook/`

Webhook events include push and pull request events.

The webhook endpoint received GitHub events. Push events triggered Jenkins builds.

Note: A successful webhook HTTP 200 response confirms delivery to the endpoint; it does not independently prove that a Jenkins job was triggered. The Jenkins job monitors the feature branch, so PR merge events targeting `dev` are not automatically equivalent to a feature-branch build.

### Docker Compose Deployment

The deployment uses three services:

| Service | Container | Port |
|---|---|---|
| Frontend | rent-a-ride-frontend | 3001:8080 |
| Backend | rent-a-ride-backend | 3000:3000 |
| MongoDB | rent-a-ride-mongodb | 27018:27017 |

Backend MongoDB connection:

`mongodb://mongodb:27017/rent_a_ride`

Docker Compose health checks are configured for the services. MongoDB data is persisted through a named volume.

### Environment Variables and Credentials

Sensitive environment variables are not committed to GitHub.

Backend environment file on EC2:

`/etc/rent-a-ride/.env`

Jenkins credentials:

- `dockerhub-rent-a-ride`
- `github-rent-a-ride`

AWS ECR access is provided through the EC2 IAM role:

`RentARide-EC2-ECR-Role`

### Deployment Verification

The following checks were performed on EC2.

Check running containers:

`docker ps`

Verified containers:

- rent-a-ride-frontend
- rent-a-ride-backend
- rent-a-ride-mongodb

Frontend health check:

`curl -I http://localhost:3001`

Expected result: `HTTP 200 OK`

Backend API check:

`curl -i http://localhost:3000/api/user/listAllVehicles`

Expected result: `HTTP 200 OK`

Frontend-to-backend proxy check:

`curl -i http://localhost:3001/api/user/listAllVehicles`

Expected result: `HTTP 200 OK`

Public API check:

`curl http://13.233.133.133:3001/api/user/listAllVehicles`

Expected result: `HTTP 200 OK`

Public access was tested after allowing inbound TCP port 3001 in the EC2 Security Group.

### Troubleshooting

**1. Docker Permission Denied**

Add the Ubuntu user to the Docker group:

`sudo usermod -aG docker ubuntu`

Reconnect to SSH and verify:

`groups`

**2. Check Container Status**

`docker ps`

**3. Check Container Logs**

`docker logs rent-a-ride-backend`

`docker logs rent-a-ride-frontend`

`docker logs rent-a-ride-mongodb`

**4. Check Docker Compose Services**

`docker compose ps`

**5. Test Backend API**

`curl http://localhost:3000/api/user/listAllVehicles`

**6. Test Nginx API Proxy**

`curl http://localhost:3001/api/user/listAllVehicles`

**7. Public Access Timeout**

Check the EC2 Security Group inbound rules and confirm that TCP port 3001 is allowed from the intended source.

### Data Protection and Best Practices

- Never commit `.env` files or credentials.
- Do not delete the MongoDB persistent volume during normal deployments.
- Avoid `docker compose down -v` because it deletes named volumes.
- Keep AWS IAM permissions restricted to required actions.
- Remove unused AWS resources after completing the lab to avoid unnecessary charges.

### Result

The Rent-a-Ride CI/CD pipeline was implemented using Jenkins and Docker Compose.

The frontend, backend, and MongoDB containers were verified as healthy. Backend API requests were tested directly and through the Nginx frontend proxy. Public API access returned HTTP 200.

The pipeline publishes application images to Docker Hub and AWS ECR and deploys the application on AWS EC2.

---

## 33. Task 9: Kubernetes Deployment on AWS EC2 Using Kind

### 1. Objective

Deploy the Rent-a-Ride application on a Kubernetes cluster running on AWS EC2 using Kind.

The deployment includes:

- React frontend served through Nginx.
- Node.js and Express backend.
- MongoDB database.
- Kubernetes Deployments, StatefulSet and Services.
- Persistent storage for MongoDB.
- ConfigMaps and Kubernetes Secrets.
- Health checks and application connectivity verification.

### 2. Environment and Infrastructure

The following environment was used:

| Component | Configuration |
|---|---|
| Cloud Provider | AWS |
| Region | ap-south-1 |
| EC2 Instance | t2.medium |
| Operating System | Ubuntu 24.04 |
| Docker Engine | 29.9.3 |
| Kind | v0.30.0 |
| Kubernetes Node Image | kindest/node:v1.34.0 |
| kubectl | v1.35.9 |
| Kind Cluster | task9-cluster |
| Kubernetes Namespace | rent-a-ride |

The Kind cluster contains:

- 1 control-plane node.
- 2 worker nodes.

### 3. Kubernetes Architecture

Application request flow:

Browser → EC2 Host Port 8080 → Kind NodePort 30080 → Frontend Nginx → Backend Service Port 3000 → MongoDB Service Port 27017.

MongoDB stores its persistent data using a 2Gi PersistentVolumeClaim.

The Kubernetes API server remains bound to localhost on the EC2 host and is not exposed publicly.

### 4. Kubernetes Resources

| Component | Kubernetes Resource | Purpose |
|---|---|---|
| Namespace | Namespace | Application isolation |
| Frontend | Deployment | Runs frontend container |
| Frontend | NodePort Service | Exposes frontend |
| Backend | Deployment | Runs Express API |
| Backend | ClusterIP Service | Internal API access |
| MongoDB | StatefulSet | Runs database |
| MongoDB | ClusterIP Service | Internal database access |
| MongoDB | PersistentVolumeClaim | Persistent database storage |
| Backend | ConfigMap | Non-sensitive configuration |
| MongoDB | ConfigMap | Database initialization script |
| Backend | Secret | JWT signing keys |

### 5. Container Images

The following images were used:

- Backend: rent-a-ride-backend:task9-1
- Frontend: rent-a-ride-frontend:task7-3
- MongoDB: mongo:8.0

The backend and frontend application images were stored in AWS ECR.

Existing ECR repositories were reused rather than recreated.

### 6. Application Configuration

The Kubernetes namespace is:

`rent-a-ride`

The backend connects to MongoDB through Kubernetes service discovery:

`mongodb://mongodb:27017/rent_a_ride`

The backend receives configuration through a ConfigMap and sensitive JWT signing keys through a Kubernetes Secret.

The Secret is created directly in the cluster. Its actual values must not be committed to Git.

### 7. MongoDB Initialization and Persistence

A MongoDB initialization script was mounted through the `mongodb-init` ConfigMap.

The script inserts sample vehicle and masterdata records when the respective collections are empty.

MongoDB uses a 2Gi PersistentVolumeClaim.

The PVC was verified as Bound.

Important: MongoDB initialization scripts in the official image run when the database directory is first initialized. Recreating a ConfigMap does not automatically rerun initialization against an existing database.

Do not delete the PVC during normal troubleshooting because doing so can result in database data loss.

### 8. Backend Startup and Health Checks

The backend startup logic was updated to wait for a successful MongoDB connection before starting the Express server.

The MongoDB connection handling was corrected using async/await.

A `/health` endpoint was added to report backend and database connectivity.

Kubernetes startup, readiness and liveness probes were configured for the backend and MongoDB workloads.

### 9. Deployment and Verification

Kubernetes manifests are stored in:

`k8s/`

Apply the manifests:

`kubectl apply -f k8s/`

Check cluster nodes:

`kubectl get nodes -o wide`

Check application resources:

`kubectl get all -n rent-a-ride`

Check persistent volume claims:

`kubectl get pvc -n rent-a-ride`

Check backend rollout:

`kubectl rollout status deployment/backend -n rent-a-ride`

Check MongoDB rollout:

`kubectl rollout status statefulset/mongodb -n rent-a-ride`

Check backend logs:

`kubectl logs deployment/backend -n rent-a-ride`

Check MongoDB logs:

`kubectl logs mongodb-0 -n rent-a-ride`

### 10. Application Connectivity Testing

The following tests were performed.

**Backend Health Endpoint**

Request:

`http://backend:3000/health`

Result:

`HTTP 200 OK`

Response:

`{"status":"healthy","database":"connected"}`

**Backend Vehicle API**

Request:

`http://backend:3000/api/user/listAllVehicles`

Result:

`HTTP 200 OK`

The API returned five seeded vehicle records.

**Frontend Nginx Reverse Proxy**

Request:

`http://127.0.0.1:8080/api/user/listAllVehicles`

Result:

`HTTP 200 OK`

The response contained vehicle records retrieved through the frontend Nginx reverse proxy.

**Frontend Homepage**

Request:

`http://127.0.0.1:8080/`

Result:

`HTTP 200 OK`

The Nginx frontend returned the application HTML successfully.

### 11. EC2 Port Mapping and Security

Kind NodePort 30080 is mapped to EC2 host port 8080.

The frontend can be accessed through:

`http://<EC2-PUBLIC-IP>:8080`

The EC2 Security Group must allow inbound TCP port 8080 from the intended client IP address.

Security recommendations:

- Restrict SSH port 22 to the administrator's IP address.
- Do not expose MongoDB port 27017 publicly.
- Do not expose Kubernetes API port 6443 publicly.
- Keep backend services internal to the Kubernetes cluster unless external access is specifically required.

### 12. Troubleshooting

**Issue 1: Backend JWT Authentication Error**

Error:

`secretOrPrivateKey must have a value`

Cause:

The backend did not receive ACCESS_TOKEN and REFRESH_TOKEN environment variables.

Fix:

Created a Kubernetes Secret named `backend-secrets` with newly generated JWT signing keys and referenced it in the backend Deployment.

Verification:

Backend rollout completed and the backend server started successfully.

Note: Newly generated JWT keys do not validate sessions signed using previous signing keys.

**Issue 2: Backend MongoDB Startup Dependency**

Issue:

The backend required MongoDB to be available before starting the application.

Fix:

Updated backend startup logic to wait for the MongoDB connection using async/await.

Verification:

Backend logs confirmed MongoDB connectivity and database name `rent_a_ride`.

**Issue 3: MongoDB Probe Timeout**

Issue:

MongoDB health probes encountered startup timeouts.

Fix:

Configured startup, readiness and liveness probes with a longer timeout to allow database initialization.

Verification:

MongoDB reached 1/1 Running and its PVC remained Bound.

**Issue 4: Frontend and Backend Communication**

Issue:

Frontend API requests needed to reach the backend through Kubernetes networking.

Fix:

Configured a backend ClusterIP Service and Nginx reverse proxy.

Verification:

The frontend proxy API returned HTTP 200 with five vehicle records.

**Issue 5: External Frontend Access**

Issue:

The frontend required access through the EC2 host port.

Fix:

Mapped Kind NodePort 30080 to EC2 host port 8080 and configured the corresponding Security Group inbound rule.

Verification:

The frontend homepage and API were successfully tested locally on the EC2 host. External browser access depends on the Security Group allowing port 8080.

### 13. Best Practices

- Use Deployments for stateless frontend and backend services.
- Use StatefulSets and PersistentVolumeClaims for database workloads.
- Use ClusterIP Services for internal application communication.
- Use ConfigMaps for non-sensitive configuration.
- Use Kubernetes Secrets for sensitive values.
- Configure startup, readiness and liveness probes.
- Use resource requests and limits.
- Keep database and Kubernetes API ports private.
- Preserve database PVCs during troubleshooting.
- Use versioned container image tags.
- Validate manifests before applying changes.

### 14. Known Limitations

- This is a learning environment, not a production high-availability deployment.
- MongoDB runs as a single replica using local-path storage.
- MongoDB authentication has not been enabled.
- Existing Docker Compose database users are not automatically migrated to the Kubernetes database.
- Newly generated JWT keys do not preserve old login sessions.
- Cloudinary, Razorpay, email and other external integrations require valid credentials and have not all been verified.
- Vite frontend environment variables are build-time settings; Kubernetes runtime variables cannot modify an already-built frontend bundle.
- Public browser access depends on the EC2 Security Group allowing inbound TCP port 8080.

### 15. Result

The Rent-a-Ride application was deployed on a three-node Kind Kubernetes cluster running on AWS EC2.

The frontend, backend and MongoDB workloads reached Running state. MongoDB persistence was verified, backend health checks succeeded, and the vehicle API returned five seeded records.

The frontend Nginx reverse proxy successfully forwarded API requests to the backend, returning HTTP 200.

The deployment demonstrates Kubernetes workload management, service discovery, persistent storage, configuration management, health checks and application connectivity verification.
