
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
