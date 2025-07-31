// Registration and login handle

import express from "express";
import { readJSON, writeJSON } from "../utils/fileHandler";
import path from "path";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; 

const router = express.Router();

// File path of users.json
const usersFile = path.resolve("server/data/users.json");

const JWT_SECRET = process.env.JWT_SECRET;

/**
 * @route POST /auth/register
 * @desc REgister new users
 * @body {email, password}
 */
router.post("/register", async (req, res) => {
    try {
        const {email, password} = req.body;

        if(!email || !password) {
            return res.status(400).json({message: "Email and password required"});
        }

        const users = await readJSON(usersFile);

        // Check if user already exists
        const existing = users.find((u) => u.email === email);
        if(existing) {
            return res.status(400).json({message: "User already exists"});
        }

        // Hash password
        const hashed = await bcrypt.hash(password, 10);

        // create new user
        const newUser = {
            id: Date.now(),
            email,
            password: hashed,
        };

        users.push(newUser);
        await writeJSON(usersFile, users);

        res.status(201).json({message: "Registration successful"});
    } catch(error) {
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
        const {email, password} = req.body;

        if (!email || !password) {
            return res.status(400).json({ message: "Email e password richieste" });
        }
        
        const users = await readJSON(usersFile);

        const user = users.find((u) => u.email === email);
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
        res.status(500).json({message: "Server error", error: error.message});
    }
});

export default router;