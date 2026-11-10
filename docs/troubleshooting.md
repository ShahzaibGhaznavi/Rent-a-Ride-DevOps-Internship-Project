
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