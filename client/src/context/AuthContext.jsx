// To handle authentication and session, since using localstorage, I'm creating a Context

import {
    createContext,
    useContext,
    useEffect,
    useState
} from 'react'

const AuthContext = createContext()

export const AuthProvider = ({ children }) => {
    const [user, setUser] = useState(null)

    useEffect(() => {
        const saved = JSON.parse(localStorage.getItem("loggedUser"))
        if(saved) setUser(saved)
    }, [])

    const login = (email, password) => {
        const users = JSON.parse(localStorage.getItem("users")) || []
        const existingUser = users.find(user => user.email === email && user.password === password)

        if(existingUser) {
            setUser(existingUser)
            localStorage.setItem("loggedUser", JSON.stringify(existingUser))
            return true
        }
        return false
    }

    const register = (email, password) => {
        const users = JSON.parse(localStorage.getItem("users")) || []

        if(users.find(user => user.email === email)) return false

        const newUser = { email, password }
        users.push(newUser)

        localStorage.setItem("users", JSON.stringify(users))
        setUser(newUser)
        localStorage.setItem("loggedUser", JSON.stringify(newUser))
        return true
    }

    const logout = () => {
        setUser(null)
        localStorage.removeItem("loggedUser")
    }

    return (
        <AuthContext.Provider value={{ user, login, register, logout }}>
            {children}
        </AuthContext.Provider>
    )
}

export const useAuth = () => useContext(AuthContext)