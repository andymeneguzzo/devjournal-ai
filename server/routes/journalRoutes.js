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

// GET /journal
router.get("/", authMiddleware, async (req, res) => {
    try {
        const allEntries = await readJSON(entriesFile);
        const userEntries = allEntries.filter(entry => entry.userId === req.userId);
        userEntries.sort((a,b) => new Date(b.date) - new Date(a.date));
        res.json(userEntries);
    } catch(error) {
        console.error("GET /journal error:", error);
        res.status(500).json({message: "Server error", error: error.message});
    }
});

// POST /journal
router.post("/", authMiddleware, async (req, res) => {
    try {
        if (!req.body || typeof req.body !== 'object') {
            return res.status(400).json({message: "Invalid request body"});
        }

        const { text } = req.body;

        if (!text || typeof text !== 'string') {
            return res.status(400).json({message: "Entry cannot be empty"});
        }

        const trimmedText = text.trim();
        if (trimmedText.length === 0) {
            return res.status(400).json({message: "Entry cannot be empty"});
        }

        const allEntries = await readJSON(entriesFile);

        const newEntry = {
            id: Date.now(),
            userId: req.userId,
            text: trimmedText,
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

// DELETE /journal/:id
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