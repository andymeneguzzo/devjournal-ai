// entry point for server Express

import express from "express";
import cors from "cors";
import dotenv from "dotenv";

import authRoutes from "./routes/authRoutes.js";
import journalRoutes from "./routes/journalRoutes.js";

dotenv.config();

const app = express();
const PORT = process.env.PORT || 5001;

// Add comprehensive error handling
process.on('unhandledRejection', (reason, promise) => {
    console.error('🚨 Unhandled Promise Rejection:', reason);
    console.error('At promise:', promise);
    // Don't exit process, just log the error
});

process.on('uncaughtException', (error) => {
    console.error('🚨 Uncaught Exception:', error);
    // For uncaught exceptions, we should exit gracefully
    setTimeout(() => process.exit(1), 1000);
});

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

// Add global error handling middleware
app.use((err, req, res, next) => {
    console.error('🚨 Global error handler:', err);
    res.status(500).json({ 
        message: "Internal server error",
        error: process.env.NODE_ENV === 'development' ? err.message : 'Something went wrong'
    });
});

// Handle 404s - this must be AFTER all other routes
app.use((req, res) => {
    res.status(404).json({ message: `Route ${req.originalUrl} not found` });
});

// Server start
app.listen(PORT, () => {
    console.log(`✅ Server AI Journal avviato su http://localhost:${PORT}`);
});