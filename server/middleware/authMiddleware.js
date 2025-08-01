// middleware for authentication JWT, protectes the journal route

import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

export function authMiddleware(req, res, next) {
    const authHeader = req.headers.authorization;

    if(!authHeader || !authHeader.startsWith("Bearer ")) {
        return res.status(401).json({message: "Access denied: token missing"});
    }

    const token = authHeader.split(" ")[1];

    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET);
        req.user = decoded; // add user info to the request
        req.userId = decoded.id; // for consistency
        next();
    } catch(error) {
        return res.status(403).json({message: "Invalid token"});
    }
}