// Journaling page with full CRUD operations

import { useAuth } from "../context/AuthContext"
import {
    useEffect,
    useState
} from "react"
import { getEntries, addEntry, updateEntry, deleteEntry } from "../../services/api"

export default function Journal() {
    const { user } = useAuth()
    const [entries, setEntries] = useState([])
    const [text, setText] = useState("")
    const [editingId, setEditingId] = useState(null)
    const [editText, setEditText] = useState("")
    const [error, setError] = useState("")
    const [loading, setLoading] = useState(false)

    useEffect(() => {
        if(!user) return;
        loadEntries();
    }, [user]);

    const loadEntries = async () => {
        try {
            setLoading(true);
            const data = await getEntries(user.token);
            setEntries(Array.isArray(data) ? data : []);
            setError("");
        } catch (error) {
            setError("Failed to load entries: " + error.message);
            console.error("Load entries error:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleSubmit = async (e) => {
        e.preventDefault()

        // Avoid empty entries
        if(!text.trim()) return;

        try {
            setLoading(true);
            const newEntry = await addEntry(user.token, text.trim());
            setEntries([newEntry, ...entries]);
            setText("");
            setError("");
        } catch (error) {
            setError("Failed to add entry: " + error.message);
            console.error("Add entry error:", error);
        } finally {
            setLoading(false);
        }
    }

    const handleEdit = (entry) => {
        setEditingId(entry.id);
        setEditText(entry.text);
    };

    const handleUpdate = async (id) => {
        if (!editText.trim()) return;

        try {
            setLoading(true);
            const updatedEntry = await updateEntry(user.token, id, editText.trim());
            setEntries(entries.map(entry => 
                entry.id === id ? updatedEntry : entry
            ));
            setEditingId(null);
            setEditText("");
            setError("");
        } catch (error) {
            setError("Failed to update entry: " + error.message);
            console.error("Update entry error:", error);
        } finally {
            setLoading(false);
        }
    };

    const handleDelete = async (id) => {
        if (!confirm("Are you sure you want to delete this entry?")) return;

        try {
            setLoading(true);
            await deleteEntry(user.token, id);
            setEntries(entries.filter(entry => entry.id !== id));
            setError("");
        } catch (error) {
            setError("Failed to delete entry: " + error.message);
            console.error("Delete entry error:", error);
        } finally {
            setLoading(false);
        }
    };

    const cancelEdit = () => {
        setEditingId(null);
        setEditText("");
    };

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

                    {error && (
                        <div className="alert alert-error">
                            {error}
                        </div>
                    )}

                    <form onSubmit={handleSubmit} className="space-y-lg">
                        <div className="form-group">
                            <label className="form-label">What's on your mind today?</label>
                            <textarea
                                className="form-input form-textarea"
                                rows={4}
                                placeholder="Write your thoughts, feelings, or experiences..."
                                value={text}
                                onChange={(e) => setText(e.target.value)}
                                disabled={loading}
                            />
                        </div>
                        
                        <button
                            className="btn btn-primary btn-full btn-lg"
                            disabled={!text.trim() || loading}
                        >
                            {loading ? "Saving..." : "Save Entry"}
                        </button>
                    </form>

                    <div className="space-y-lg">
                        <h2 className="text-display-sm">Your Journal Entries</h2>
                        
                        {loading && entries.length === 0 ? (
                            <div className="card-entry text-center">
                                <p className="text-muted">Loading entries...</p>
                            </div>
                        ) : (
                            <div className="space-y-md animate-stagger">
                                {entries.length === 0 && (
                                    <div className="card-entry text-center">
                                        <p className="text-muted">No entries yet. Start writing your first one!</p>
                                    </div>
                                )}
                                {entries.map((entry) => (
                                    <div
                                        key={entry.id}
                                        className="card-entry animate-fade-in"
                                    >
                                        {editingId === entry.id ? (
                                            <div className="space-y-md">
                                                <textarea
                                                    className="form-input form-textarea w-full"
                                                    rows={3}
                                                    value={editText}
                                                    onChange={(e) => setEditText(e.target.value)}
                                                    disabled={loading}
                                                />
                                                <div className="flex gap-sm">
                                                    <button
                                                        className="btn btn-primary btn-sm"
                                                        onClick={() => handleUpdate(entry.id)}
                                                        disabled={!editText.trim() || loading}
                                                    >
                                                        {loading ? "Saving..." : "Save"}
                                                    </button>
                                                    <button
                                                        className="btn btn-ghost btn-sm"
                                                        onClick={cancelEdit}
                                                        disabled={loading}
                                                    >
                                                        Cancel
                                                    </button>
                                                </div>
                                            </div>
                                        ) : (
                                            <>
                                                <p className="text-body">{entry.text}</p>
                                                <div className="flex justify-between items-center mt-md">
                                                    <div className="text-body-sm text-muted">
                                                        {new Date(entry.date).toLocaleString()}
                                                    </div>
                                                    <div className="flex gap-sm">
                                                        <button
                                                            className="btn btn-ghost btn-sm"
                                                            onClick={() => handleEdit(entry)}
                                                            disabled={loading}
                                                        >
                                                            Edit
                                                        </button>
                                                        <button
                                                            className="btn btn-ghost btn-sm text-error"
                                                            onClick={() => handleDelete(entry.id)}
                                                            disabled={loading}
                                                        >
                                                            Delete
                                                        </button>
                                                    </div>
                                                </div>
                                            </>
                                        )}
                                    </div>
                                ))}
                            </div>
                        )}
                    </div>
                </div>
            </div>
        </div>
    );
}