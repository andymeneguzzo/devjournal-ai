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

// import Home from './pages/Home' obscuring because still not developed
import Login from './pages/Login'
// import Register from './pages/Register' obscuring because still not developed
import Journal from './pages/Journal'

function ProtectedRoute({ children }) {
  const { user } = useAuth()
  return user ? children : <Navigate to="/login"/>
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="/login" element={<Login />} />
          <Route path="/register" element={<Register />} />
          <Route path="/journal" element={<ProtectedRoute><Journal /></ProtectedRoute>} />
        </Routes>
      </BrowserRouter>
    </AuthProvider>
  )
}