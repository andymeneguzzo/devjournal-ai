import { Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Home() {
  const { user, logout } = useAuth()

  return (
    <div className="page-container-with-navbar">
      <div className="content-container animate-slide-up">
        <div className="card card-body text-center">
          <h1 className="text-display-lg gradient-text">AI Journal</h1>
          <p className="text-body-lg">
            Write your thoughts and let AI help you reflect, grow, and improve every day.
          </p>

          {user ? (
            <div className="space-y-lg">
              <div className="text-body">
                Ready to continue your journey?
              </div>
              <div className="space-y-md">
                <Link
                  to="/journal"
                  className="btn btn-primary btn-full btn-lg"
                >
                  Open Journal
                </Link>
              </div>
            </div>
          ) : (
            <div className="space-y-md">
              <div className="text-body">
                Start your personal growth journey today
              </div>
              <div className="space-x-md flex justify-center">
                <Link
                  to="/login"
                  className="btn btn-ghost"
                >
                  Login
                </Link>
                <Link
                  to="/register"
                  className="btn btn-primary"
                >
                  Get Started
                </Link>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  )
}
