import {
  BrowserRouter, 
  Routes,
  Route,
  Navigate
} from 'react-router-dom'

import {
  AuthProvider,
  useAuth
} from './context/AuthContext'

// pages
import Home from './pages/Home'
import Login from './pages/Login'
import Register from './pages/Register'
import Journal from './pages/Journal'

// components
import Navbar from './components/Navbar'


function ProtectedRoute({ children }) {
  const { user } = useAuth()
  return user ? children : <Navigate to="/login"/>
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Navbar />
        <div className="pt-16"> {/* padding per non coprire il contenuto */}
          <Routes>
            <Route path="/" element={<Home />} />
            <Route path="/login" element={<Login />} />
            <Route path="/register" element={<Register />} />
            <Route path="/journal" element={<ProtectedRoute><Journal /></ProtectedRoute>} />
          </Routes>
        </div>
      </BrowserRouter>
    </AuthProvider>
  )
}