// Handle CRUD operations on entries

import express from "express";
import { readJSON, writeJSON } from "../utils/fileHandler";
import path from "path";
import { authMiddleware } from "../middleware/authMiddleware";

const router = express.Router();
const entriesFile = path.resolve("server/data/entries.json");


/**
 * @route GET /journal
 * @desc Get all entries of logged user
 */
router.get("/", authMiddleware, async (req, res) => {
    try {
        const allEntries = await readJSON(entriesFile);
        const userEntries = allEntries.filter(entry => entry.userId === req.userId);

        // Order from most recent
        userEntries.sort((a,b) => new Date(b.date) - new Date(a.date));

        res.json(userEntries);
    } catch(error) {
        res.status(500).json({message: "Server error", error: error.message});
    }
});

// missing POST & DELETE operations...