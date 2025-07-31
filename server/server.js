// entry point for server Express

import express from "express";
import cors from "cors";
import fs from "fs";
import path from "path";

import authRoutes from "./routes/authRoutes.js";
import journalRoutes from "./routes/journalRoutes.js";

const app = express();
const PORT = process.env.PORT || 5000;

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use("/auth", authRoutes);
app.use("/journal", journalRoutes);

// Server start
app.listen(PORT, () => {
    console.log(`✅ Server AI Journal avviato su http://localhost:${PORT}`);
});