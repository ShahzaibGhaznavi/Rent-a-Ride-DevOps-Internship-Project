# Troubleshooting and Setup Notes

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
