// Journaling page

import { useAuth } from "../context/AuthContext"
import {
    useEffect,
    useState
} from "react"

export default function Journal() {
    const { user } = useAuth()
    const [entries, setEntries] = useState([])
    const [text, setText] = useState("")

    useEffect(() => {
        if(!user) return 
        const stored = JSON.parse(localStorage.getItem(`entries_${user.email}`)) || []
        setEntries(stored)
    }, [user])

    const handleSubmit = (e) => {
        e.preventDefault()

        const newEntry = { text, date: new Date().toISOString() }
        const updated = [...entries, newEntry]
        localStorage.setItem(`entries_${user.email}`, JSON.stringify(updated))
        setEntries(updated)
        setText("")
    }

    if(!user) return <div>Unauthorized access</div>

    return (
    <div className="p-4 max-w-2xl mx-auto">
      <h1 className="text-3xl font-bold mb-4">Hi, {user.email}</h1>
      <form onSubmit={handleSubmit} className="mb-6">
        <textarea
          className="w-full border rounded p-2 mb-2"
          rows={4}
          placeholder="Write your diary..."
          value={text}
          onChange={(e) => setText(e.target.value)}
        />
        <button className="bg-green-500 text-white px-4 py-2 rounded">Save</button>
      </form>
      <div className="space-y-4">
        {entries.map((e, idx) => (
          <div key={idx} className="bg-white p-4 rounded shadow">
            <p className="mb-2">{e.text}</p>
            <span className="text-sm text-gray-500">{new Date(e.date).toLocaleString()}</span>
          </div>
        ))}
      </div>
    </div>
  )
}