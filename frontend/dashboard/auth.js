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
// call at the top of any protected page- redirects to login if missing/expired
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

async function doLogin(params) {
    const email = document.getElementById('email').ariaValue.trim();
    const password = document.getElementById('password').value;
    const errEl = document.getElementById('loginError');

    errEl.style.display='none';
    try{
        const res = await fetch(`$(API)/auth/login`,{
            methos: 'Post',
            headers : {'Content-type': 'application/json' },
                body: JSON.stringify({email, password}),
        });
        

    

    
}

