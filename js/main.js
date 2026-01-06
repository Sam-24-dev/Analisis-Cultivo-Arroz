/**
 * Rice Crop Analytics - Main Application
 * Loads data from JSON files and renders dashboard
 */

const API_BASE = './data';

const cultivoData = {
    employees: [],
    financial: [],
    areas: [],
    kpis: {},
    trends: [],
    recommendations: [],
    dashboard: {}
};

// Data Loading Functions
async function fetchJSON(filename) {
    try {
        const response = await fetch(`${API_BASE}/${filename}`);
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        return await response.json();
    } catch (error) {
        console.error(`Error loading ${filename}:`, error);
        return null;
    }
}

async function loadAllData() {
    console.log('Loading data from JSON files...');

    const [employees, financial, areas, kpis, trends, recommendations, dashboard] = await Promise.all([
        fetchJSON('employees.json'),
        fetchJSON('financial.json'),
        fetchJSON('areas.json'),
        fetchJSON('kpis.json'),
        fetchJSON('trends.json'),
        fetchJSON('recommendations.json'),
        fetchJSON('dashboard.json')
    ]);

    if (employees) cultivoData.employees = employees;
    if (financial) cultivoData.financial = financial;
    if (areas) cultivoData.areas = areas;
    if (kpis) cultivoData.kpis = kpis;
    if (trends) cultivoData.trends = trends;
    if (recommendations) cultivoData.recommendations = recommendations;
    if (dashboard) cultivoData.dashboard = dashboard;

    console.log('Data loaded:', {
        employees: cultivoData.employees.length,
        financial: cultivoData.financial.length,
        areas: cultivoData.areas.length
    });

    return cultivoData;
}

// Utility Functions
function formatCurrency(value) {
    if (value === null || value === undefined || isNaN(value)) return 'N/A';
    return '$' + Number(value).toLocaleString('en-US', {
        minimumFractionDigits: 2,
        maximumFractionDigits: 2
    });
}

function formatPercentage(value) {
    if (value === null || value === undefined || isNaN(value)) return 'N/A';
    return Number(value).toFixed(1) + '%';
}

function formatNumber(value, decimals = 1) {
    if (value === null || value === undefined || isNaN(value)) return 'N/A';
    return Number(value).toLocaleString('en-US', {
        minimumFractionDigits: decimals,
        maximumFractionDigits: decimals
    });
}

function getStatusBadge(roi) {
    if (roi === null || roi === undefined) return '<span class="badge bg-secondary">No data</span>';
    if (roi > 100) return '<span class="badge bg-success">Excellent</span>';
    if (roi > 0) return '<span class="badge bg-primary">Positive</span>';
    if (roi > -50) return '<span class="badge bg-warning">Regular</span>';
    return '<span class="badge bg-danger">Critical</span>';
}

function getEfficiencyColor(efficiency) {
    if (efficiency >= 100) return 'success';
    if (efficiency >= 80) return 'primary';
    if (efficiency >= 60) return 'warning';
    return 'danger';
}

function getRankingIcon(ranking) {
    switch (ranking) {
        case 1: return '<i class="fas fa-trophy text-warning"></i>';
        case 2: return '<i class="fas fa-medal text-secondary"></i>';
        case 3: return '<i class="fas fa-award text-warning"></i>';
        default: return `<span class="badge bg-light text-dark">${ranking}</span>`;
    }
}

// Chart Colors - matching new CSS theme
const chartColors = {
    primary: '#059669',      // Emerald green
    success: '#22c55e',      // Green
    warning: '#f59e0b',      // Amber
    danger: '#ef4444',       // Red
    info: '#3b82f6',         // Blue
    secondary: '#1e40af',    // Deep blue
    light: '#f3f4f6',
    dark: '#1f2937',
    green: '#10b981',
    brown: '#92400e',
    orange: '#f97316'
};

// CSV Export Function
function exportTableToCSV(tableId, filename = 'data.csv') {
    const table = document.getElementById(tableId);
    if (!table) return;

    let csv = [];
    const rows = table.querySelectorAll('tr');

    for (let i = 0; i < rows.length; i++) {
        const row = [], cols = rows[i].querySelectorAll('td, th');

        for (let j = 0; j < cols.length; j++) {
            let cellData = cols[j].innerText.replace(/"/g, '""');
            row.push('"' + cellData + '"');
        }

        csv.push(row.join(','));
    }

    downloadCSV(csv.join('\n'), filename);
}

function downloadCSV(csv, filename) {
    const csvFile = new Blob([csv], { type: 'text/csv' });
    const downloadLink = document.createElement('a');

    downloadLink.download = filename;
    downloadLink.href = window.URL.createObjectURL(csvFile);
    downloadLink.style.display = 'none';

    document.body.appendChild(downloadLink);
    downloadLink.click();
    document.body.removeChild(downloadLink);
}

// Loading Animation
function showLoading(elementId) {
    const element = document.getElementById(elementId);
    if (element) {
        element.innerHTML = '<div class="text-center"><div class="loading"></div></div>';
    }
}

function hideLoading(elementId, content) {
    const element = document.getElementById(elementId);
    if (element) {
        element.innerHTML = content;
    }
}

// Initialize tooltips
function initializeTooltips() {
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
}

// Navigation active state
function setActiveNavigation() {
    const currentPage = window.location.pathname.split('/').pop();
    const navLinks = document.querySelectorAll('.nav-link');

    navLinks.forEach(link => {
        const href = link.getAttribute('href');
        if (href === currentPage || (currentPage === '' && href === 'index.html')) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }
    });
}

// Card hover effects
function initializeCardEffects() {
    const cards = document.querySelectorAll('.card');
    cards.forEach(card => {
        card.addEventListener('mouseenter', function () {
            this.style.transform = 'translateY(-2px)';
        });

        card.addEventListener('mouseleave', function () {
            this.style.transform = 'translateY(0)';
        });
    });
}

// Button click animation
function initializeButtonEffects() {
    const buttons = document.querySelectorAll('.btn');
    buttons.forEach(button => {
        button.addEventListener('click', function () {
            this.style.transform = 'scale(0.95)';
            setTimeout(() => {
                this.style.transform = 'scale(1)';
            }, 150);
        });
    });
}

// Initialize application
async function initApp() {
    console.log('Initializing Rice Crop Analytics...');

    await loadAllData();

    initializeTooltips();
    setActiveNavigation();
    initializeCardEffects();
    initializeButtonEffects();

    // Dispatch event for page-specific initialization
    window.dispatchEvent(new CustomEvent('dataLoaded', { detail: cultivoData }));

    console.log('Application initialized');
}

// Start when DOM is ready
document.addEventListener('DOMContentLoaded', initApp);

// Export for use in other modules
window.cultivoData = cultivoData;
window.formatCurrency = formatCurrency;
window.formatPercentage = formatPercentage;
window.formatNumber = formatNumber;
window.getStatusBadge = getStatusBadge;
window.getEfficiencyColor = getEfficiencyColor;
window.getRankingIcon = getRankingIcon;
window.chartColors = chartColors;