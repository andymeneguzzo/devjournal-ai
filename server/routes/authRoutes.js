// Registration and login handle

import express from "express";
import { readJSON, writeJSON } from "../utils/fileHandler.js";
import path from "path";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; 
import { fileURLToPath } from "url";
import dotenv from "dotenv";

dotenv.config();
const router = express.Router();

// Fix file path resolution for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const usersFile = path.join(__dirname, "../data/users.json");

const JWT_SECRET = process.env.JWT_SECRET;
// Add debugging to verify JWT_SECRET is loaded
if (!JWT_SECRET) {
    console.error("❌ JWT_SECRET is not defined! Check your .env file.");
    process.exit(1);
}

/**
 * @route POST /auth/register
 * @desc Register new users
 * @body {email, password}
 */
router.post("/register", async (req, res) => {
    try {
        // Ensure req.body exists and is an object
        if (!req.body || typeof req.body !== 'object') {
            return res.status(400).json({message: "Invalid request body"});
        }

        const {email, password} = req.body;

        // Basic validation first - check for missing/falsy values
        if (!email || !password || typeof email !== 'string' || typeof password !== 'string') {
            return res.status(400).json({message: "Email and password required"});
        }

        // Trim and validate email format - ONLY if email exists and is string
        const trimmedEmail = email.trim();
        if (!trimmedEmail) {
            return res.status(400).json({message: "Email and password required"});
        }

        const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
        if (!emailRegex.test(trimmedEmail)) {
            return res.status(400).json({message: "Invalid email format"});
        }

        // Password strength validation - ONLY if password exists and is string  
        if (password.length < 6) {
            return res.status(400).json({message: "Password must be at least 6 characters"});
        }

        const users = await readJSON(usersFile);

        // Check if user already exists
        const existing = users.find((u) => u.email === trimmedEmail);
        if(existing) {
            return res.status(400).json({message: "User already exists"});
        }

        // Hash password
        const hashed = await bcrypt.hash(password, 10);

        // create new user
        const newUser = {
            id: Date.now(),
            email: trimmedEmail,
            password: hashed,
        };

        users.push(newUser);
        await writeJSON(usersFile, users);

        res.status(201).json({message: "Registration successful"});
    } catch(error) {
        console.error("Registration error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

/**
 * @route POST /auth/login
 * @desc Login and return a JWT token
 * @body {email, password}
 */
router.post("/login", async (req,res) => {
    try {
        // Ensure req.body exists and is an object
        if (!req.body || typeof req.body !== 'object') {
            return res.status(400).json({message: "Invalid request body"});
        }

        const {email, password} = req.body;

        // Basic validation - check for missing/falsy values
        if (!email || !password || typeof email !== 'string' || typeof password !== 'string') {
            return res.status(400).json({ message: "Email and password required" });
        }
        
        const users = await readJSON(usersFile);
        const trimmedEmail = email.trim();

        const user = users.find((u) => u.email === trimmedEmail);
        if(!user) {
            return res.status(400).json({message: "User doesn't exist"});
        }

        const match = await bcrypt.compare(password, user.password);
        if(!match) {
            return res.status(400).json({message: "Wrong password"});
        }

        // Generate JWT token valid for 2 hours
        const token = jwt.sign({id: user.id, email: user.email}, JWT_SECRET, {
            expiresIn: "2h",
        });

        res.json({message: "Login successful", token});
    } catch(error) {
        console.error("Login error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

export default router;