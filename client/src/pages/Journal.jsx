// Journaling page

import { useAuth } from "../context/AuthContext"
import {
    useEffect,
    useState
} from "react"
import { getEntries, addEntry } from "../../services/api"

export default function Journal() {
    const { user } = useAuth()
    const [entries, setEntries] = useState([])
    const [text, setText] = useState("")

    useEffect(() => {
      if(!user) return;
      (async () => {
        const data = await getEntries(user.token);
        setEntries(data);
      })();
    }, [user]);

    const handleSubmit = async (e) => {
        e.preventDefault()

        // Avoid empty entries
        if(!text.trim()) return;

        const newEntry = await addEntry(user.token, text);
        setEntries([newEntry, ...entries]);
        setText("");
    }

    if (!user) return (
        <div className="page-container">
            <div className="content-container">
                <div className="card card-body text-center">
                    <div className="text-error font-semibold">Unauthorized access</div>
                </div>
            </div>
        </div>
    );

    return (
        <div className="page-container">
            <div className="content-container-lg animate-slide-up">
                <div className="card card-body">
                    <h1 className="text-display-md text-center">
                        Hi, <span className="gradient-text">{user.email}</span>
                    </h1>

                    <form onSubmit={handleSubmit} className="space-y-lg">
                        <div className="form-group">
                            <label className="form-label">What's on your mind today?</label>
                            <textarea
                                className="form-input form-textarea"
                                rows={4}
                                placeholder="Write your thoughts, feelings, or experiences..."
                                value={text}
                                onChange={(e) => setText(e.target.value)}
                            />
                        </div>
                        
                        <button
                            className="btn btn-primary btn-full btn-lg"
                            disabled={!text.trim()}
                        >
                            Save Entry
                        </button>
                    </form>

                    <div className="space-y-lg">
                        <h2 className="text-display-sm">Your Journal Entries</h2>
                        
                        <div className="space-y-md animate-stagger">
                            {entries.length === 0 && (
                                <div className="card-entry text-center">
                                    <p className="text-muted">No entries yet. Start writing your first one!</p>
                                </div>
                            )}
                            {entries.map((e) => (
                                <div
                                    key={e.id}
                                    className="card-entry animate-fade-in"
                                >
                                    <p className="text-body">{e.text}</p>
                                    <div className="text-body-sm text-muted">
                                        {new Date(e.date).toLocaleString()}
                                    </div>
                                </div>
                            ))}
                        </div>
                    </div>
                </div>
            </div>
        </div>
    );
}