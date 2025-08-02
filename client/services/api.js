// service to centralize the api calls

const API_URL = "http://localhost:5001";

// Helper function to handle API responses
async function handleResponse(response) {
    if (!response.ok) {
        const errorData = await response.json().catch(() => ({ message: 'Network error' }));
        throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
    }
    return response.json();
}

// ====== AUTHENTICATION API ======
export async function registerUser(email, password) {
    const response = await fetch(`${API_URL}/auth/register`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({email, password}),
    });
    return handleResponse(response);
}

export async function loginUser(email, password) {
    const response = await fetch(`${API_URL}/auth/login`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({email, password}),
    });
    return handleResponse(response);
}

// ====== JOURNAL API ======
export async function getEntries(token) {
    const response = await fetch(`${API_URL}/journal`, {
        headers: { Authorization: `Bearer ${token}` },
    });
    return handleResponse(response);
}

export async function addEntry(token, text) {
    const response = await fetch(`${API_URL}/journal`, {
        method: "POST",
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ text }),
    });
    return handleResponse(response);
}

export async function updateEntry(token, id, text) {
    const response = await fetch(`${API_URL}/journal/${id}`, {
        method: "PUT",
        headers: {
            "Content-Type": "application/json",
            Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ text }),
    });
    return handleResponse(response);
}

export async function deleteEntry(token, id) {
    const response = await fetch(`${API_URL}/journal/${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${token}` },
    });
    return handleResponse(response);
}