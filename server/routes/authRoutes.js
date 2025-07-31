// Registration and login handle

import express from "express";
import { readJSON,
     writeJSON } from "../utils/fileHandler";
import path from "path";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken"; 

const router = express.Router();

// File path of users.json
const userFile = path.resolve("server/data/users.json");

// const JWT_SECRET = "use_env_variable";

/**
 * @route POST /auth/register
 * @desc REgister new users
 * @body {email, password}
 */
rout
