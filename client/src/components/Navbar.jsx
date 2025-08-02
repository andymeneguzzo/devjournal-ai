// Navigation bar for the App

import { Link, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Navbar() {
    const { user, logout } = useAuth()
    const navigate = useNavigate()

    const handleLogout = () => {
        logout()
        navigate('/')
    }

    return (
        <nav className="fixed top-0 left-0 w-full z-50 glass-effect border-b border-white/20">
            <div className="max-w-6xl mx-auto px-6">
                <div className="flex justify-between items-center h-16">
                    {/* Logo / Brand */}
                    <Link 
                        to="/" 
                        className="text-display-sm gradient-text hover:scale-105 transition-transform duration-200"
                    >
                        AI Journal
                    </Link>

                    {/* Navigation Links */}
                    <div className="flex items-center space-x-lg">
                        {user ? (
                            <>
                                <div className="text-body-sm text-muted">
                                    Welcome, <span className="font-medium text-success">{user.email}</span>
                                </div>
                                <Link
                                    to="/journal"
                                    className="btn btn-ghost btn-sm"
                                >
                                    Journal
                                </Link>
                                <button
                                    onClick={handleLogout}
                                    className="btn btn-secondary btn-sm"
                                >
                                    Logout
                                </button>
                            </>
                        ) : (
                            <>
                                <Link
                                    to="/login"
                                    className="btn btn-ghost btn-sm"
                                >
                                    Login
                                </Link>
                                <Link
                                    to="/register"
                                    className="btn btn-primary btn-sm"
                                >
                                    Register
                                </Link>
                            </>
                        )}
                    </div>
                </div>
            </div>
        </nav>
    )
}