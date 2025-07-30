import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Home() {
  const { user, logout } = useAuth()

  return (
    <div className="flex items-center justify-center h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md text-center max-w-md w-full">
        <h1 className="text-3xl font-bold mb-4">📝 AI Journal</h1>
        <p className="text-gray-600 mb-6">
          Wirte your thoughts and the AI will help you work on them and improve.
        </p>

        {user ? (
          <div>
            <p className="text-lg mb-4">Welcome back, <span className="font-semibold">{user.email}</span>!</p>
            <Link to="/journal" className="block bg-green-500 text-white px-4 py-2 rounded mb-3 hover:bg-green-600">
              Go to your Diary
            </Link>
            <button
              onClick={logout}
              className="w-full bg-red-500 text-white px-4 py-2 rounded hover:bg-red-600"
            >
              Logout
            </button>
          </div>
        ) : (
          <div>
            <Link to="/login" className="block bg-blue-500 text-white px-4 py-2 rounded mb-3 hover:bg-blue-600">
              Login
            </Link>
            <Link to="/register" className="block bg-gray-500 text-white px-4 py-2 rounded hover:bg-gray-600">
              Register
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}
