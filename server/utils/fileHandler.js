// helper functions for reading and writing in file JSON

import fs from "fs";
import path from "path";

/**
 * Reads data from JSON file
 * @param {string} filePath
 * @returns {Promise<any>}
 */
export async function readJSON(filePath) {
    return new Promise((resolve, reject) => {
        fs.readFile(filePath, "utf-8", (err, data) => {
            if(err) {
                if(err.code === "ENOENT") {
                    return resolve([]); // if file doesn't exist, initialize empty
                }
                return reject(err);
            }
            try {
                resolve(JSON.parse(data || "[]"));
            } catch(parseErr) {
                reject(parseErr);
            }
        });
    });
}

/**
 * Writes data on file JSON
 * @param {string} filePath
 * @param {any} data
 * @returns {Promise<void>}
 */
export async function writeJSON(filePath, data) {
    return withFileLock(filePath, () => {
        return new Promise((resolve, reject) => {
            const jsonData = JSON.stringify(data, null, 2);
            fs.writeFile(filePath, jsonData, "utf-8", (err) => {
                if(err) {
                    console.error("File write error:", err);
                    return reject(err);
                }
                resolve();
            });
        });
    });
}

// Add file operation mutex to prevent race conditions
const fileLocks = new Map();

async function withFileLock(filePath, operation) {
    if (fileLocks.has(filePath)) {
        await fileLocks.get(filePath);
    }
    
    const lockPromise = operation();
    fileLocks.set(filePath, lockPromise);
    
    try {
        const result = await lockPromise;
        return result;
    } finally {
        fileLocks.delete(filePath);
    }
}