// service to centralize the api calls

const API_URL = "http://localhost:5001";

export async function registerUser(email, password) {
    const res = await fetch(`${API_URL}/auth/register`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({email, password}),
    });
    
    return res.json();
}

export async function loginUser(email, password) {
    const res = await fetch(`${API_URL}/auth/login`, {
        method: "POST",
        headers: {"Content-Type": "application/json"},
        body: JSON.stringify({email, password}),
    });

    return res.json();
}

export async function getEntries(token) {
  const res = await fetch(`${API_URL}/journal`, {
    headers: { Authorization: `Bearer ${token}` },
  });
  return res.json();
}

export async function addEntry(token, text) {
  const res = await fetch(`${API_URL}/journal`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      Authorization: `Bearer ${token}`,
    },
    body: JSON.stringify({ text }),
  });
  return res.json();
}