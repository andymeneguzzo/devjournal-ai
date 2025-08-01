// Handle CRUD operations on entries

import express from "express";
import { readJSON, writeJSON } from "../utils/fileHandler.js";
import path from "path";
import { authMiddleware } from "../middleware/authMiddleware.js";
import { fileURLToPath } from "url";

const router = express.Router();

// Fix file path resolution for ES modules
const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const entriesFile = path.join(__dirname, "../data/entries.json");

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
        console.error("GET /journal error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

/**
 * @route POST /journal
 * @desc Add a new entry
 * @body {text}
 */
router.post("/", authMiddleware, async (req, res) => {
    try {
        const { text } = req.body;

        // More robust validation
        if (typeof text !== 'string' || text.trim().length === 0) {
            return res.status(400).json({message: "Entry cannot be empty"});
        }

        const allEntries = await readJSON(entriesFile);

        const newEntry = {
            id: Date.now(),
            userId: req.userId,
            text: text.trim(), // Ensure clean text
            date: new Date().toISOString()
        };

        allEntries.push(newEntry);
        await writeJSON(entriesFile, allEntries);

        res.status(201).json(newEntry);
    } catch(error) {
        console.error("POST /journal error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

/**
 * @route DELETE /journal/:id
 * @desc Delete a specific user entry
 */
router.delete("/:id", authMiddleware, async (req, res) => {
    try {
        const entryId = parseInt(req.params.id);
        
        if (isNaN(entryId)) {
            return res.status(400).json({message: "Invalid entry ID"});
        }

        const allEntries = await readJSON(entriesFile);
        const index = allEntries.findIndex(entry => entry.id === entryId && entry.userId === req.userId);

        if(index === -1) {
            return res.status(404).json({message: "Entry not found or unathorized"});
        }

        allEntries.splice(index, 1);
        await writeJSON(entriesFile, allEntries);

        res.json({message: "Entry removed successfully"});
    } catch(error) {
        console.error("DELETE /journal error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

export default router;