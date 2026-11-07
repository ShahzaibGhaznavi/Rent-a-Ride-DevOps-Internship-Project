
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

- **Frontend:** Multi-stage build using Node.js 24 Alpine and Nginx Alpine.
- **Backend:** Node.js 22 Alpine container.
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

## 16. Docker containerization architecture

**Implementation:** Containerized the frontend, backend, and MongoDB using
Docker and Docker Compose.

Services:

- **Frontend:** Multi-stage build using Node.js 24 Alpine and Nginx Alpine.
- **Backend:** Node.js 22 Alpine container.
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
