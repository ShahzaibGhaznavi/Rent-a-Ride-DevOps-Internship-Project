import express from "express";
import mongoose from "mongoose";
import dotenv from "dotenv";
import userRoute from "./routes/userRoute.js";
import authRoute from "./routes/authRoute.js";
import adminRoute from "./routes/adminRoute.js";
import vendorRoute from "./routes/venderRoute.js";
import cors from "cors";
import cookieParser from "cookie-parser";
import { cloudinaryConfig } from "./utils/cloudinaryConfig.js";

dotenv.config();

const App = express();
const port = 3000;

App.use(express.json());
App.use(cookieParser());

const allowedOrigins = [
  "https://rent-a-ride-two.vercel.app",
  "http://localhost:5173",
];

App.use(
  cors({
    origin: allowedOrigins,
    methods: ["GET", "PUT", "POST", "PATCH", "DELETE"],
    credentials: true,
  })
);

App.get("/health", (req, res) => {
  const connected = mongoose.connection.readyState === 1;

  return res.status(connected ? 200 : 503).json({
    status: connected ? "healthy" : "unhealthy",
    database: connected ? "connected" : "disconnected",
  });
});

App.use("*", cloudinaryConfig);

App.use("/api/user", userRoute);
App.use("/api/auth", authRoute);
App.use("/api/admin", adminRoute);
App.use("/api/vendor", vendorRoute);

App.use((err, req, res, next) => {
  const statusCode = err.statusCode || 500;
  const message = err.message || "internal server error";

  return res.status(statusCode).json({
    success: false,
    message,
    statusCode,
  });
});

async function startServer() {
  if (!process.env.mongo_uri) {
    throw new Error("mongo_uri environment variable is missing");
  }

  await mongoose.connect(process.env.mongo_uri, {
    serverSelectionTimeoutMS: 15000,
  });

  console.log("MongoDB connected successfully");
  console.log(`Database: ${mongoose.connection.name}`);

  App.listen(port, "0.0.0.0", () => {
    console.log(`Server listening on port ${port}`);
  });
}

mongoose.connection.on("error", (error) => {
  console.error("MongoDB connection error:", error);
});

startServer().catch((error) => {
  console.error("Backend startup failed:", error);
  process.exit(1);
});
