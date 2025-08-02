// Register page

import { useState } from 'react'
import { useNavigate, Link } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Register() {
    const [email, setEmail] = useState('')
    const [password, setPassword] = useState('')
    const [confirmPassword, setConfirmPassword] = useState('')
    const { register } = useAuth()
    const navigate = useNavigate()

    const handleSubmit = (e) => {
        e.preventDefault()

        if(password !== confirmPassword) {
            alert("Passwords don't match")
            return
        }

        const success = register(email, password)
        if(success) navigate('/journal')
        else alert('Email already exists, try logging in')
    }

    return (
        <div className="page-container">
            <div className="content-container animate-slide-up">
                <div className="card card-body">
                    <h2 className="text-display-md text-center gradient-text">Create an account</h2>
                    
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
                                placeholder="Create a password"
                                value={password}
                                onChange={(e) => setPassword(e.target.value)}
                                required
                                className="form-input"
                            />
                        </div>
                        
                        <div className="form-group">
                            <label className="form-label">Confirm Password</label>
                            <input
                                type="password"
                                placeholder="Confirm your password"
                                value={confirmPassword}
                                onChange={(e) => setConfirmPassword(e.target.value)}
                                required
                                className="form-input"
                            />
                        </div>
                        
                        <button className="btn btn-primary btn-full btn-lg">
                            Create Account
                        </button>
                    </form>

                    <div className="text-body-sm text-center text-muted">
                        Already have an account?{' '}
                        <Link to="/login" className="text-success font-medium hover:underline">
                            Login here
                        </Link>
                    </div>
                </div>
            </div>
        </div>
    )
}