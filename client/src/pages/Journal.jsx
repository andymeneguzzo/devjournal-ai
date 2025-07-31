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

        // Avoid empty entries
        if(!text.trim()) return;

        const newEntry = { text, date: new Date().toISOString() }

        // the last published first
        const updated = [newEntry, ...entries]
        localStorage.setItem(`entries_${user.email}`, JSON.stringify(updated))
        setEntries(updated)
        setText("")
    }

    if (!user) return <div className="text-center p-10 text-red-500 font-bold">Unauthorized access</div>

  return (
    <div className="flex items-center justify-center min-h-screen bg-gray-100">
      <div className="bg-white p-8 rounded-lg shadow-md w-full max-w-2xl">
        <h1 className="text-3xl font-bold mb-6 text-center">Hi, {user.email}</h1>

        <form onSubmit={handleSubmit} className="mb-6">
          <textarea
            className="w-full border rounded p-3 mb-3 focus:ring-2 focus:ring-green-400 outline-none"
            rows={4}
            placeholder="Write your diary..."
            value={text}
            onChange={(e) => setText(e.target.value)}
          />
          <button
            className="w-full bg-green-500 text-white px-4 py-2 rounded hover:bg-green-600 transition-colors disabled:bg-gray-300 disabled:cursor-not-allowed"
            disabled={!text.trim()}
          >
            Save Entry
          </button>
        </form>

        <div className="space-y-4">
          {entries.length === 0 && (
            <p className="text-gray-500 text-center">No entries yet. Start writing your first one!</p>
          )}
          {entries.map((e, idx) => (
            <div
              key={idx}
              className="bg-gray-50 p-4 rounded shadow hover:shadow-md transition-shadow"
            >
              <p className="mb-2">{e.text}</p>
              <span className="text-sm text-gray-500">
                {new Date(e.date).toLocaleString()}
              </span>
            </div>
          ))}
        </div>
      </div>
    </div>
  )
}