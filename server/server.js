// entry point for server Express

import express from "express";
import cors from "cors";
import dotenv from "dotenv";

import authRoutes from "./routes/authRoutes.js";
import journalRoutes from "./routes/journalRoutes.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Middleware
app.use(cors({
    origin: "http://localhost:5173",
    methods: ["GET", "POST", "DELETE", "PATCH", "OPTIONS"],
    allowedHeaders: ["Content-Type", "Authorization"]
}));

app.use(express.json());

// Routes
app.use("/auth", authRoutes);
app.use("/journal", journalRoutes);

// Server start
app.listen(PORT, () => {
    console.log(`✅ Server AI Journal avviato su http://localhost:${PORT}`);
});