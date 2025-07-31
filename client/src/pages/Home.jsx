import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Home() {
  const { user, logout } = useAuth()

  return (
    <div className="flex items-center justify-center min-h-screen px-4 bg-[var(--color-bg)]">
      <div className="text-center w-full max-w-md">
        <h1 className="text-4xl font-bold mb-3">AI Journal</h1>
        <p className="text-lg mb-8">
          Write your thoughts and let AI help you reflect, grow, and improve every day.
        </p>

        {user ? (
          <div>
            <p className="text-lg mb-4">
              Welcome back, <span className="font-semibold">{user.email}</span>!
            </p>
            <Link
              to="/journal"
              className="btn btn-login block w-full mb-3 text-center"
            >
              Go to your Journal
            </Link>
            <button
              onClick={logout}
              className="btn btn-register w-full"
            >
              Logout
            </button>
          </div>
        ) : (
          <div className="flex justify-center gap-4">
            <Link
              to="/login"
              className="btn btn-login"
            >
              Login
            </Link>
            <Link
              to="/register"
              className="btn btn-register"
            >
              Register
            </Link>
          </div>
        )}
      </div>
    </div>
  )
}
