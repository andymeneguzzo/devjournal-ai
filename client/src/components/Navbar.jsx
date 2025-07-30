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
    <nav className="bg-white shadow-md fixed top-0 left-0 w-full z-10">
      <div className="max-w-6xl mx-auto px-4">
        <div className="flex justify-between items-center h-14">
          {/* Logo / Brand */}
          <Link to="/" className="text-xl font-bold text-blue-600 hover:text-blue-800">
            AI Journal
          </Link>

          {/* Links */}
          <div className="flex space-x-4">
            {user ? (
              <>
                <Link
                  to="/journal"
                  className="text-gray-700 hover:text-blue-600 font-medium"
                >
                  Diario
                </Link>
                <button
                  onClick={handleLogout}
                  className="bg-red-500 text-white px-3 py-1 rounded hover:bg-red-600"
                >
                  Logout
                </button>
              </>
            ) : (
              <>
                <Link
                  to="/login"
                  className="text-gray-700 hover:text-blue-600 font-medium"
                >
                  Login
                </Link>
                <Link
                  to="/register"
                  className="bg-blue-500 text-white px-3 py-1 rounded hover:bg-blue-600"
                >
                  Registrati
                </Link>
              </>
            )}
          </div>
        </div>
      </div>
    </nav>
  )
}