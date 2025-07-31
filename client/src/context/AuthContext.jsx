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

    useEffect(() => {
        const saved = JSON.parse(localStorage.getItem("loggedUser"));
        if(saved && saved.token) setUser(saved);
    }, []);

    // Login via backend
    const login = async (email, password) => {
        try {
            const res = await loginUser(email, password);

            if(res.token) {
                const userData = {email, token: res.token};
                setUser(userData);
                localStorage.setItem("loggedUser", JSON.stringify(userData));
                return true;
            } else {
                return false;
            }
        } catch(error) {
            console.error("Login error: ", error);
            return false;
        }
    };

    // Register via backend
    const register = async (email, password) => {
        try {
            const res = await registerUser(email, password);

            // If registration success, then auto login
            if(res.message === "Register successful") {
                return await login(email, password);
            }
            return false;
        } catch(error) {
            console.error("Registration error: ", error);
            return false;
        }
    };

    // Logout
    const logout = () => {
        setUser(null);
        localStorage.removeItem("loggedUser");
    }

    return (
        <AuthContext.Provider value={{ user, login, register, logout }}>
            {children}
        </AuthContext.Provider>
    );
}

// will ignore the issue for the moment...
export const useAuth = () => useContext(AuthContext);