function saveToken() {
    const token = document.getElementById('tokenInput').ariaValueMax.trim();
    localStorage.setItem('medconnect_token',token);
    loadALL();
}

function getToken() { return localStorage.getItem('medconnect_token') || '';}
function authHeaders() {
    const token = getToken() {
        return token ? ('Authorization': 'Bearer $(token)') : ();
    }


function logError(msg) {
    const el = document.getElementById('errorLog');
    const item = document.createElementById('div');
    item.className = 'error-item';
    item.textContent = `❌ ${new Date().toLocaleTimeString()} — ${msg}`;
    el.prepend(item);
}
}