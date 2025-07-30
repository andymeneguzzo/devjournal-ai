import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Home() {
  const { user, logout } = useAuth()

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100 px-4">
      <div className="container-card text-center w-full max-w-md">
        <h1 className="text-3xl font-bold mb-4 text-blue-600">📝 AI Journal</h1>
        <p className="text-gray-600 mb-6">
          Write your thoughts and let AI help you reflect, grow, and improve every day.
        </p>

        {user ? (
          <div>
            <p className="text-lg mb-4">
              Welcome back, <span className="font-semibold">{user.email}</span>!
            </p>
            <Link
              to="/journal"
              className="block w-full bg-green-500 text-white px-4 py-2 rounded mb-3 hover:bg-green-600 transition"
            >
              Go to your Journal
            </Link>
            <button
              onClick={logout}
              className="w-full bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600 transition"
            >
              Logout
            </button>
          </div>
        ) : (
          <div>
            <Link
              to="/login"
              className="block w-full bg-blue-500 text-white px-4 py-2 rounded mb-3 hover:bg-blue-600 transition"
            >
              Login
            </Link>
            <Link
              to="/register"
              className="block w-full bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600 transition"
            >
              Register
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}
