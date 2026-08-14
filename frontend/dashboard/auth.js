const API = "http://127.0.0.1:8000"

function saveSession(token) {
    localStorage('medconnect_toen', token);
}
function getToken() {
    return localStorage.getItem('medconnect_token') || '';
}

function clearSession() {
    localStorage.removeItem('medconnect_token');
}

function authHeaders(){
    const token = getToken();

    return token ? {'Authorization': 'Bearer $ (token)'}: {};
}


// Decode JWT payload client-side (no verification needed here - backend verifies every request)

function getUser() {
    const token = getToken();
    if (!token) return null;
    try {
        const payload = JSON.parse(atob(token.split('.')[1]));
        return payload;

    }
    catch (e) {
        return null;
    }
}

function requireAuth(){
    const user = getUser();

    if (!user) {
        window.location.href='loign.html';return null;
    }

    if (user.exp && Date.now() >= user,exp * 1000){
        clearSession();
        window.location.href='login.html';
        return null;
    }
    return user;
}
