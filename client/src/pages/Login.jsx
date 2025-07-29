// Login page

import { useState } from 'react'
import { useNavigate } from 'react-router-dom'
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
    <div className="flex items-center justify-center h-screen bg-gray-100">
      <form onSubmit={handleSubmit} className="bg-white p-6 rounded shadow-md w-96">
        <h2 className="text-2xl font-bold mb-4">Login</h2>
        <input type="email" className="w-full mb-4 p-2 border rounded" placeholder="Email"
          value={email} onChange={(e) => setEmail(e.target.value)} />
        <input type="password" className="w-full mb-4 p-2 border rounded" placeholder="Password"
          value={password} onChange={(e) => setPassword(e.target.value)} />
        <button className="w-full bg-blue-500 text-white p-2 rounded hover:bg-blue-600">Log In</button>
      </form>
    </div>
  )
}