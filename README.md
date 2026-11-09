# Rent a Ride

A full-stack car rental platform with three modules: **User, Admin, and Vendor**. The application allows users to browse and book vehicles, vendors to manage vehicle listings, and administrators to manage bookings, users, and vendors.

The project is divided into two main parts:

- `client/` – Frontend application
- `backend/` – Backend application code

## Table of Contents

- [Project Overview](#project-overview)
- [Features and Modules](#features-and-modules)
- [Technology Stack](#technology-stack)
- [Project Structure](#project-structure)
- [Installation and Setup](#installation-and-setup)
- [Environment Configuration](#environment-configuration)
- [Features and Implementations](#features-and-implementations)
- [DevOps Improvements](#devops-improvements)
- [Deployment](#deployment)
- [Screenshots](#screenshots)
- [Docker Deployment](#docker-deployment)

## Project Overview

Rent a Ride is a full-scale car rental platform designed to provide a seamless vehicle booking and management experience.

The application supports three different roles:

- **Users:** Browse available vehicles, manage profiles, and book vehicles.
- **Admins:** Manage bookings, users, vendors, and vehicle listings.
- **Vendors:** Register, list vehicles, and receive booking updates.

## Features and Modules

### 1. User Module

- **View and Book Vehicles:** Browse available vehicles and book them online.
- **Profile Management:** View and update profile information and account settings.
- **Order Management:** View past and upcoming bookings.
- **Account Management:** Sign up, sign in, and manage account access.
- **Email Notifications:** Receive booking confirmation emails with order details.

### 2. Admin Module

- **Booking Management:** View and manage bookings, including booking details and statuses.
- **Vendor Management:** Review, approve, reject, or remove vendors.
- **Vehicle Management:** View, update, and delete vehicle listings.
- **User Management:** Manage and remove users from the platform.

### 3. Vendor Module

- **Registration and Login:** Separate sign-up and sign-in functionality for vendors.
- **Vehicle Listing:** Add vehicles for admin approval.
- **Vehicle Management:** Manage submitted vehicle listings.
- **Order Notifications:** Receive updates when users book listed vehicles.

## Technology Stack

| Component | Technologies |
|---|---|
| Frontend | React.js, JavaScript, Vite |
| State Management | Redux Toolkit |
| UI and Styling | Material UI, Tailwind CSS |
| Form Validation | React Hook Form, Zod |
| Backend | Node.js, Express.js |
| Database | MongoDB |
| Authentication | JWT, Google OAuth |
| Payments | Razorpay |
| File Uploads | Multer |
| Media Storage | Cloudinary |
| Email Service | Nodemailer |
| Web Server | Nginx |
| Process Management | PM2 |
| Cloud Platform | AWS EC2 |
| DNS Management | Cloudflare |
| Containerization | Docker, Docker Compose |

## Project Structure

```text
Rent-a-Ride/
│
├── backend/
│   ├── controllers/
│   ├── models/
│   ├── routes/
│   ├── services/
│   ├── utils/
│   ├── Dockerfile
│   └── server.js
│
├── client/
│   ├── src/
│   ├── public/
│   ├── Dockerfile
│   ├── nginx.conf
│   ├── package.json
│   └── vite.config.js
│
├── docs/
│   └── troubleshooting.md
│
├── mongo-init/
│   └── 01-seed.js
│
├── .dockerignore
├── .env.example
├── .gitignore
├── docker-compose.yml
├── package.json
└── README.md
```

## Installation and Setup

### Prerequisites

Make sure the following tools are installed:

- Node.js and npm
- Git
- MongoDB connection
- Required service credentials for integrations such as Cloudinary, Razorpay, and email

### 1. Clone the Repository

```bash
git clone https://github.com/ShahzaibGhaznavi/Rent-a-Ride-DevOps-Internship-Project.git

cd Rent-a-Ride-DevOps-Internship-Project
```

### 2. Install Backend Dependencies

The backend `package.json` is located in the project root directory.

```bash
npm install
```

### 3. Configure Backend Environment Variables

Create your local backend environment file:

```bash
cp .env.example .env
```

Update `.env` with your own valid credentials.

### 4. Start the Backend

From the project root directory:

```bash
npm run dev
```

### 5. Install Frontend Dependencies

Open a second terminal:

```bash
cd client

npm install
```

### 6. Configure Frontend Environment Variables

```bash
cp .env.example .env
```

Update the frontend environment variables with the required values.

### 7. Start the Frontend

```bash
npm run dev
```

The frontend and backend will run in separate terminals. Use the local URLs displayed by the development servers.

## Environment Configuration

The project requires environment variables for database connectivity, authentication, payments, email services, and third-party integrations.

### Backend Environment Variables

The root `.env.example` provides the backend configuration template.

```env
mongo_uri=mongodb_connection_string

ACCESS_TOKEN=your_access_token
REFRESH_TOKEN=your_refresh_token

RAZORPAY_KEY_ID=your_razorpay_key_id
RAZORPAY_SECRET=your_razorpay_secret

EMAIL_HOST=your_email
EMAIL_PASSWORD=your_email_password

CLOUD_NAME=your_cloudinary_cloud_name
API_KEY=your_cloudinary_api_key
API_SECRET=your_cloudinary_api_secret
```

### Frontend Environment Variables

The `client/.env.example` file provides the frontend configuration template.

```env
VITE_FIREBASE_API_KEY=your_firebase_api_key
VITE_PRODUCTION_BACKEND_URL=http://localhost:3000
VITE_RAZORPAY_KEY_ID=your_razorpay_key_id
```

### Important Security Notes

- Never commit actual `.env` files to Git.
- Never expose passwords, API secrets, database credentials, or private keys.
- Only public configuration values should be exposed to frontend code.
- Razorpay Secret must remain on the backend.
- Use `.env.example` files as templates rather than storing real credentials in the repository.

## Features and Implementations

- **JWT Authentication:** Access and refresh tokens are used for authentication.
- **Role-Based Access Control:** Protected routes restrict access based on User, Admin, and Vendor roles.
- **Dynamic Location Selector:** Pickup and drop-off options update according to the selected location.
- **Search, Sort, and Filter:** Vehicle browsing functionality supports searching, sorting, and filtering.
- **Form Validation:** React Hook Form and Zod provide form validation.
- **Google OAuth:** Supports Google-based sign-up and sign-in.
- **Email Notifications:** Nodemailer handles booking-related email notifications.
- **Cloudinary Integration:** Cloudinary is used for image and video storage.
- **MongoDB:** Database models and referencing are used to organize application data.
- **Multer:** Handles vehicle image and video uploads.
- **Version Control:** Git is used for source code management and collaboration.

## DevOps Improvements

The repository has been prepared for DevOps internship practice, focusing on Git workflow, repository management, application configuration, containerization, networking, data persistence, and documentation.

The following improvements have been made:

- **Private Repository Setup:** Maintained an independent private GitHub repository for internship work.
- **Gitflow Branching Strategy:** Created `main`, `dev`, `stg`, and `feature/shahzaib-azeem` branches.
- **Environment Templates:** Added `.env.example` files for backend and frontend configuration.
- **Frontend Configuration Fix:** Updated the Razorpay frontend environment variable to use Vite's required `VITE_` prefix.
- **Git Ignore Cleanup:** Removed duplicate `package-lock.json` ignore entries so dependency lockfiles can be tracked.
- **Docker Containerization:** Created Dockerfiles for frontend and backend applications.
- **Docker Compose:** Configured frontend, backend, and MongoDB services.
- **Nginx Reverse Proxy:** Configured frontend Nginx to forward API requests to the backend container.
- **MongoDB Persistence:** Configured the named Docker volume `rent-a-ride_mongodb_data` to preserve database records.
- **Custom Docker Network:** Created a dedicated bridge network named `rent-a-ride-network` for communication between frontend, backend, and MongoDB containers.
- **Persistence Verification:** Verified MongoDB data persistence by restarting the database container and confirming that existing records remained intact.
- **Database Seed Data:** Added an initialization script for sample vehicles and masterdata.
- **Documentation:** Updated installation instructions and documented setup, networking, persistence, and troubleshooting steps.

### Git Branching Strategy

```text
main
 |
 └── stg
      |
      └── dev
           |
           └── feature/shahzaib-azeem
```

Feature development is carried out on the feature branch, followed by a Pull Request to `dev`.

## Deployment

The original application deployment architecture uses:

- **AWS EC2:** Application hosting.
- **Nginx:** Reverse proxy.
- **Cloudflare:** DNS management.
- **PM2:** Node.js process management.

Deployment configuration and credentials should be maintained separately from the source code.

## Screenshots

### User Module

![User Screenshot 1](https://github.com/user-attachments/assets/4b769f7d-5d2c-43a7-8283-07fa8402de92)

![User Screenshot 2](https://github.com/user-attachments/assets/5d6e0160-5f1d-4e67-a64e-1e18fb17a590)

![User Screenshot 3](https://github.com/user-attachments/assets/ac6b0f33-344e-4009-a979-23ea7dc3a5bb)

![User Screenshot 4](https://github.com/user-attachments/assets/40e2dc7d-0694-483d-bf4a-badac9c4d5f3)

![User Screenshot 5](https://github.com/user-attachments/assets/7ce5d1fa-c51f-414b-92da-cc04ac7c3402)

![User Screenshot 6](https://github.com/user-attachments/assets/0e87009c-832d-4c5e-be7c-ecd4df341070)

![User Screenshot 7](https://github.com/user-attachments/assets/baf15b5d-2e04-4410-803b-527dddda1aab)

### Admin Module

![Admin Screenshot 1](https://github.com/user-attachments/assets/c08e3bf0-2776-4236-80b6-6714d52ec8d7)

![Admin Screenshot 2](https://github.com/user-attachments/assets/ce6dada8-41b7-4aec-b86a-4a359f6d339f)

![Admin Screenshot 3](https://github.com/user-attachments/assets/467503a4-ab9a-4396-bc57-1abff5fe8106)

![Admin Screenshot 4](https://github.com/user-attachments/assets/8e1d2948-6316-420b-8336-30ec7c752b04)

### Vendor Module

![Vendor Screenshot 1](https://github.com/user-attachments/assets/59a9a9c7-5dc1-4f61-8d15-43266579386c)

![Vendor Screenshot 2](https://github.com/user-attachments/assets/4e9d8f66-0984-4163-8dea-f9023db56ce0)

## Docker Deployment

The application can be built and run using Docker Compose.

### Architecture

| Service | Technology | Host Port |
|---|---|---|
| Frontend | React, Vite, Nginx | 3001 |
| Backend | Node.js, Express | 3000 |
| Database | MongoDB 8.0 | 27018 |

### Prerequisites

- Docker Desktop with Docker Compose.
- Backend environment configuration.
- Frontend Firebase API key and Razorpay public Key ID, where required.

### Environment Configuration

Create the root environment file:

```bash
cp .env.example .env
```

Configure the required backend credentials in `.env`. Set the frontend public configuration values used during the Docker build when required. Never commit actual environment files or private credentials.

### Build and Start Containers

```bash
docker compose up -d --build

docker compose ps
```

### Access the Application

- Frontend: [http://localhost:3001](http://localhost:3001)
- Backend API: [http://localhost:3000](http://localhost:3000)
- MongoDB: `localhost:27018`

The frontend Nginx server proxies `/api/` requests to the backend container through the Docker Compose network.

### Database Persistence

MongoDB uses the explicitly named Docker volume `rent-a-ride_mongodb_data`, mounted at `/data/db`, to preserve database records across container restarts and recreation.

The existing volume is reused by Docker Compose to retain previously stored data.

The `mongo-init/01-seed.js` script initializes a fresh database with five sample vehicles and fifteen masterdata records.

Initialization scripts do not automatically rerun against an existing database volume.

### Custom Docker Network

Docker Compose uses a dedicated bridge network named `rent-a-ride-network`.

All three application services are connected to this network:

- Frontend
- Backend
- MongoDB

Container communication:

- Backend connects to MongoDB using `mongodb:27017`.
- Frontend Nginx forwards API requests to `backend:3000`.

Verify the custom network:

```bash
docker network inspect rent-a-ride-network
```

The custom bridge network provides container-level network isolation and service connectivity. It does not by itself encrypt network traffic or provide application authentication.

### Data Persistence Verification

MongoDB data persistence was tested by restarting the database container:

```bash
docker compose restart mongodb
```

After restarting, the database records remained unchanged:

| Collection | Records |
|---|---:|
| vehicles | 5 |
| users | 1 |
| masterdatas | 15 |
| bookings | 0 |

This confirmed that the named Docker volume preserves database records after a container restart.

### Useful Docker Commands

View running containers:

```bash
docker compose ps
```

View container logs:

```bash
docker compose logs -f
```

Restart services:

```bash
docker compose restart
```

Stop containers:

```bash
docker compose down
```

Inspect the Docker volume:

```bash
docker volume inspect rent-a-ride_mongodb_data
```

Inspect the Docker network:

```bash
docker network inspect rent-a-ride-network
```

**Warning:** Avoid `docker compose down -v` during routine cleanup because it deletes the Compose-managed MongoDB volume and its data.

### Troubleshooting

See [Docker and Application Troubleshooting](docs/troubleshooting.md) for container startup, networking, MongoDB persistence, Nginx proxy, API verification, and known limitations.


## Task 5: Multi-Stage Docker Builds and Image Security

This task focuses on optimizing Docker images, running application containers with non-root users, verifying the full application stack, and publishing images to multiple container registries.

### 1. Backend Docker Improvements

The backend uses a multi-stage Docker build with Node.js 26 Alpine.

- Separate dependency installation and production stages.
- Installs production dependencies using `npm ci --omit=dev`.
- Copies application files with appropriate ownership.
- Runs the Node.js application as the non-root `node` user.

### 2. Frontend Docker Improvements

The frontend uses a multi-stage build.

- Node.js 26 Alpine is used to build the React/Vite application.
- Production assets are copied into `nginxinc/nginx-unprivileged:stable-alpine`.
- Nginx runs as a non-root user.
- Nginx listens on port `8080` instead of privileged port `80`.

### 3. Container Security Verification

Both application containers were checked to confirm their runtime users.

| Container | Runtime user | UID |
|---|---|---:|
| Backend | node | 1000 |
| Frontend | nginx | 101 |

Verification commands:

```bash
docker exec rent-a-ride-backend id
docker exec rent-a-ride-frontend id

Note: The application containers run as non-root users. The Docker daemon itself was not running in rootless mode during this verification. These are separate security configurations.

4. Docker Image Sizes
Image	Docker disk usage	Content size
Backend	298 MB	69 MB
Frontend	98.7 MB	29 MB

5. Full-Stack Verification

The containers were built and started successfully using Docker Compose.
Component / Test	Result
Frontend (localhost:3001)	HTTP 200
Backend API (localhost:3000)	HTTP 200
Frontend Nginx API proxy	HTTP 200
Backend runtime user	Non-root
Frontend runtime user	Non-root
MongoDB	Healthy

6. Container Registry Publishing
Both application images were published with the task5 tag to three registries.

Docker Hub
- Backend: shahzaibazeem/rent-a-ride-backend:task5
- Frontend: shahzaibazeem/rent-a-ride-frontend:task5

GitHub Container Registry (GHCR)
- Backend: ghcr.io/shahzaibghaznavi/rent-a-ride-backend:task5
- Frontend: ghcr.io/shahzaibghaznavi/rent-a-ride-frontend:task5
AWS Elastic Container Registry (ECR)

AWS Region: ap-south-1 (Mumbai)
- Backend: 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-backend:task5
- Frontend: 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-frontend:task5
Both ECR repositories were configured with scan-on-push enabled. However, scan findings were unavailable when queried, so no successful vulnerability scan result is claimed.

7. Pull Images from Registries
Docker Hub
docker pull shahzaibazeem/rent-a-ride-backend:task5
docker pull shahzaibazeem/rent-a-ride-frontend:task5


GitHub Container Registry
docker pull ghcr.io/shahzaibghaznavi/rent-a-ride-backend:task5
docker pull ghcr.io/shahzaibghaznavi/rent-a-ride-frontend:task5


AWS ECR

Authenticate first using AWS CLI:
aws ecr get-login-password --region ap-south-1 | docker login --username AWS --password-stdin 332730082659.dkr.ecr.ap-south-1.amazonaws.com


Pull the images:
docker pull 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-backend:task5
docker pull 332730082659.dkr.ecr.ap-south-1.amazonaws.com/rent-a-ride-frontend:task5


8. Known Build Limitations

The Docker builds completed successfully, but some warnings remain:
- npm reported dependency vulnerabilities and deprecated packages.
- The frontend build reported unresolved asset references.
- The frontend build reported a large JavaScript bundle warning.
- ECR scan findings were not available during verification.

Dependencies were not force-upgraded because doing so could introduce application compatibility issues. These items remain documented for future improvement.

9. Image Backup and Recovery
Docker Hub and GHCR provide additional copies of the published images. If an ECR repository is deleted, the images can be restored by pulling them from another registry, tagging them with the recreated ECR repository URI, and pushing them again.