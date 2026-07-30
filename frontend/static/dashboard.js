// frontend/dashboard/dashboard.js — connects to your REAL FastAPI backend
const API = 'http://127.0.0.1:8000';
let hospitalId = document.getElementById('hospitalFilter').value;
let charts = {};

// ── AUTH TOKEN (needed only for protected endpoints like /patients) ──
function saveToken() {
  const token = document.getElementById('tokenInput').value.trim();
  localStorage.setItem('medconnect_token', token);
  loadAll();
}
function getToken() { return localStorage.getItem('medconnect_token') || ''; }
function authHeaders() {
  const token = getToken();
  return token ? { 'Authorization': `Bearer ${token}` } : {};
}

// ── ON-SCREEN ERROR LOG (so you see errors without opening DevTools) ──
function logError(msg) {
  const el = document.getElementById('errorLog');
  const item = document.createElement('div');
  item.className = 'error-item';
  item.textContent = `❌ ${new Date().toLocaleTimeString()} — ${msg}`;
  el.prepend(item);
}

// ── KPI DISPLAY CONFIG — maps your ACTUAL 3 keys to labels/icons/colors ──
// Resilient: unmapped keys still render generically instead of breaking
const KPI_DISPLAY_MAP = {
  alos_days:    { label: 'Avg Length of Stay', unit: 'days', icon: '📅', color: '#00d97e' },
  alos_minutes: { label: 'Avg Wait Time',      unit: 'min',  icon: '⏱',  color: '#22d3ee' }, // current buggy key name
  awt_minutes:  { label: 'Avg Wait Time',      unit: 'min',  icon: '⏱',  color: '#22d3ee' }, // use this once Bug 1 fixed
  rar_percent:  { label: 'Readmission Rate',   unit: '%',    icon: '🔄',  color: '#ff6b6b' },
  bor_percent:  { label: 'Bed Occupancy',      unit: '%',    icon: '🛏',  color: '#4d9fff' },
  revenue_mtd:  { label: 'Revenue (MTD)',      unit: '₹',    icon: '💰',  color: '#ffb830' },
};

// ── FETCH + RENDER KPI CARDS ──
async function fetchKPIs() {
  try {
    const res = await fetch(`${API}/api/analytics/kpis?hospital_id=${hospitalId}`, { headers: authHeaders() });
    if (!res.ok) { logError(`KPI fetch failed (${res.status})`); return; }
    const data = await res.json();
    renderKPICards(data);
    document.getElementById('lastUpdated').textContent = 'Updated: ' + new Date().toLocaleTimeString();
  } catch (e) { logError(`KPI network error: ${e.message}`); }
}

function renderKPICards(data) {
  const grid = document.getElementById('kpiGrid');
  grid.innerHTML = '';
  Object.entries(data).forEach(([key, value]) => {
    const config = KPI_DISPLAY_MAP[key] || { label: key.replace(/_/g, ' '), unit: '', icon: '📊', color: '#9ba3c0' };
    let displayValue = typeof value === 'number' ? value.toFixed(1) : value;
    const card = document.createElement('div');
    card.className = 'kpi-card';
    card.style.setProperty('--accent', config.color);
    card.innerHTML = `
      <div class="kpi-icon">${config.icon}</div>
      <div class="kpi-val">${displayValue} <span class="kpi-unit">${config.unit}</span></div>
      <div class="kpi-label">${config.label}</div>`;
    grid.appendChild(card);
  });
}

// ── OPD TREND CHART — compute_opd_load() returns {date: count} dict ──
async function fetchOPDTrend() {
  try {
    const res = await fetch(`${API}/api/analytics/opd-trend?hospital_id=${hospitalId}`, { headers: authHeaders() });
    if (!res.ok) { logError(`OPD trend failed (${res.status})`); return; }
    const data = await res.json();
    const labels = Object.keys(data).sort();
    const values = labels.map(d => data[d]);
    if (charts.opd) charts.opd.destroy();
    charts.opd = new Chart(document.getElementById('opdChart'), {
      type: 'line',
      data: { labels: labels.length ? labels : ['No data yet'], datasets: [{
        label: 'OPD Visits', data: values.length ? values : [0],
        borderColor: '#4d9fff', backgroundColor: 'rgba(77,159,255,0.1)', fill: true, tension: 0.4, pointRadius: 4
      }]},
      options: { responsive: true, plugins: { legend: { display: false } },
        scales: { y: { beginAtZero: true, grid: { color: '#2e3250' }, ticks: { color: '#9ba3c0' } },
                  x: { grid: { color: '#2e3250' }, ticks: { color: '#9ba3c0', maxTicksLimit: 10 } } } }
    });
  } catch (e) { logError(`OPD trend network error: ${e.message}`); }
}

// ── DIAGNOSIS MIX CHART ──
async function fetchDiagnosisMix() {
  try {
    const res = await fetch(`${API}/api/analytics/diagnosis-mix?hospital_id=${hospitalId}`, { headers: authHeaders() });
    if (!res.ok) { logError(`Diagnosis mix failed (${res.status})`); return; }
    const data = await res.json();
    const labels = data.labels || Object.keys(data);
    const values = data.data || Object.values(data);
    if (charts.diag) charts.diag.destroy();
    charts.diag = new Chart(document.getElementById('diagChart'), {
      type: 'doughnut',
      data: { labels: labels.length ? labels : ['No data'], datasets: [{
        data: values.length ? values : [1],
        backgroundColor: ['#4d9fff','#00d97e','#ffb830','#a78bfa','#ff6b6b','#22d3ee'], borderWidth: 0
      }]},
      options: { responsive: true, plugins: { legend: { position: 'bottom', labels: { color: '#9ba3c0' } } }, cutout: '65%' }
    });
  } catch (e) { logError(`Diagnosis mix network error: ${e.message}`); }
}

// ── OVERVIEW BAR CHART — visual summary of whatever KPIs come back ──
async function fetchMetricsOverview() {
  try {
    const res = await fetch(`${API}/api/analytics/kpis?hospital_id=${hospitalId}`, { headers: authHeaders() });
    if (!res.ok) return;
    const data = await res.json();
    const labels = Object.keys(data).map(k => (KPI_DISPLAY_MAP[k]?.label || k));
    const values = Object.values(data);
    if (charts.overview) charts.overview.destroy();
    charts.overview = new Chart(document.getElementById('metricsChart'), {
      type: 'bar',
      data: { labels, datasets: [{ label: 'Value', data: values,
        backgroundColor: ['#4d9fff','#00d97e','#ffb830','#ff6b6b','#a78bfa','#22d3ee'], borderRadius: 6 }]},
      options: { responsive: true, plugins: { legend: { display: false } },
        scales: { y: { grid: { color: '#2e3250' }, ticks: { color: '#9ba3c0' } }, x: { grid: { display: false }, ticks: { color: '#9ba3c0' } } } }
    });
  } catch (e) { logError(`Overview chart error: ${e.message}`); }
}

// ── LOAD EVERYTHING + AUTO-REFRESH ──
async function loadAll() {
  await Promise.all([fetchKPIs(), fetchOPDTrend(), fetchDiagnosisMix(), fetchMetricsOverview()]);
}
document.getElementById('hospitalFilter').addEventListener('change', (e) => { hospitalId = e.target.value; loadAll(); });
window.addEventListener('DOMContentLoaded', () => { const saved = getToken(); if (saved) document.getElementById('tokenInput').value = saved; });
loadAll();
setInterval(loadAll, 30000);