// To handle authentication and session, since using localstorage, I'm creating a Context

import {
    createContext,
    useContext,
    useEffect,
    useState
} from 'react';
import { loginUser, registerUser } from '../../services/api';

const AuthContext = createContext();

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null);
    const [loading, setLoading] = useState(true);

    useEffect(() => {
        const saved = JSON.parse(localStorage.getItem("loggedUser"));
        if(saved && saved.token) setUser(saved);
        setLoading(false);
    }, []);

    // Login via backend
    const login = async (email, password) => {
        try {
            const res = await loginUser(email, password);

            if(res.token) {
                const userData = {email, token: res.token};
                setUser(userData);
                localStorage.setItem("loggedUser", JSON.stringify(userData));
                return { success: true };
            } else {
                return { success: false, error: "Invalid credentials" };
            }
        } catch(error) {
            console.error("Login error: ", error);
            return { success: false, error: error.message };
        }
    };

    // Register via backend
    const register = async (email, password) => {
        try {
            const res = await registerUser(email, password);

            // Fixed: Check for correct backend message
            if(res.message === "Registration successful") {
                return await login(email, password);
            }
            return { success: false, error: res.message || "Registration failed" };
        } catch(error) {
            console.error("Registration error: ", error);
            return { success: false, error: error.message };
        }
    };

    // Logout
    const logout = () => {
        setUser(null);
        localStorage.removeItem("loggedUser");
    }

    return (
        <AuthContext.Provider value={{ user, login, register, logout, loading }}>
            {children}
        </AuthContext.Provider>
    );
}

// will ignore the issue for the moment...
export const useAuth = () => useContext(AuthContext);