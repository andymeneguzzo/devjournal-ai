// Login page

import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Login() {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const { login } = useAuth()
    const navigate = useNavigate()

    const handleSubmit = (e) => {
        e.preventDefault()

        const success = login(email, password)
        if(success) navigate('/journal')
        else alert('Invalid credentials')
    }

    return (
        <div className="page-container">
            <div className="content-container animate-slide-up">
                <div className="card card-body">
                    <h2 className="text-display-md text-center gradient-text">Login to your account</h2>

                    <form onSubmit={handleSubmit} className="space-y-lg">
                        <div className="form-group">
                            <label className="form-label">Email</label>
                            <input
                                type="email"
                                placeholder="Enter your email"
                                value={email}
                                onChange={(e) => setEmail(e.target.value)}
                                required
                                className="form-input"
                            />
                        </div>
                        
                        <div className="form-group">
                            <label className="form-label">Password</label>
                            <input
                                type="password"
                                placeholder="Enter your password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                                className="form-input"
                            />
                        </div>

                        <button className="btn btn-primary btn-full btn-lg">
                            Login
                        </button>
                    </form>

                    <div className="text-body-sm text-center text-muted">
                        Don't have an account?{' '}
                        <Link to="/register" className="text-success font-medium hover:underline">
                            Register here
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    )
}