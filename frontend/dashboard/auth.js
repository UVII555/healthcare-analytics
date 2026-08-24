const API = "http://127.0.0.1:8000";

function saveSession(token) {
  localStorage.setItem('medconnect_token', token);
}

function getToken() {
  return localStorage.getItem('medconnect_token') || '';
}
function clearSession() {
  localStorage.removeItem('medconnect_token');
}
function authHeaders() {
  const token = getToken();
  return token ? { 'Authorization': `Bearer ${token}` } : {};
}

// Decode JWT payload client-side (no verification needed here — backend verifies every request)
function getUser() {
  const token = getToken();
  if (!token) return null;
  try {
    const payload = JSON.parse(atob(token.split('.')[1]));
    return payload;
  } catch (e) {
    return null;
  }
}

// Call at the top of any protected page — redirects to login if missing/expired
function requireAuth() {
  const user = getUser();
  if (!user) {
    window.location.href = 'login.html';
    return null;
  }
  if (user.exp && Date.now() >= user.exp * 1000) {
    clearSession();
    window.location.href = 'login.html';
    return null;
  }
  return user;
}

async function doLogin() {
  const email = document.getElementById('email').value.trim();
  const password = document.getElementById('password').value;
  const errEl = document.getElementById('loginError');
  errEl.style.display = 'none';
  try {
    const res = await fetch(`${API}/api/auth/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    if (!res.ok) throw new Error(`Login failed: ${res.status}`);
    const data = await res.json();
    saveSession(data.access_token);
    window.location.href = 'index.html';
  } catch (e) {
    errEl.textContent = e.message;   // shows the real status instead of always "Invalid email or password"
    errEl.style.display = 'block';
  }
}

function logout() {
  clearSession();
  window.location.href = 'login.html';
