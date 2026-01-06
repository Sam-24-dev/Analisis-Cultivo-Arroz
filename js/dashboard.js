/**
 * Rice Crop Analytics - Dashboard Module
 * Renders main dashboard charts and KPIs
 */

let dashboardRendered = false;

function renderDashboard() {
    if (dashboardRendered) return;

    const kpis = window.cultivoData.kpis || {};
    const employees = window.cultivoData.employees || [];
    const financial = window.cultivoData.financial || [];

    dashboardRendered = true;
    console.log('Rendering dashboard');

    updateKPICards(kpis);
    renderInvestmentChart(financial);
    renderTasksChart(kpis);
    renderTopEmployeesTable(employees);
}

function updateKPICards(kpis) {
    const ops = kpis.operations || {};
    const fin = kpis.finance || {};
    const prod = kpis.productivity || {};

    const activeEmployees = document.getElementById('empleados-activos');
    if (activeEmployees) activeEmployees.textContent = ops.active_employees || 6;

    const totalInvestment = document.getElementById('inversion-total');
    if (totalInvestment) totalInvestment.textContent = formatCurrency(fin.total_investment || 981);

    const totalTorvadas = document.getElementById('torvadas-totales');
    if (totalTorvadas) totalTorvadas.textContent = formatNumber(prod.total_torvadas || 28.5);

    const completionRate = document.getElementById('cumplimiento');
    if (completionRate) completionRate.textContent = formatPercentage(ops.completion_rate_pct || 72.7);
}

function renderInvestmentChart(financial) {
    const ctx = document.getElementById('inversionChart');
    if (!ctx) return;

    const labels = financial.map(f => f.activity_type || 'Unknown');
    const values = financial.map(f => f.total_investment || 0);

    const colors = [
        chartColors.success,
        chartColors.warning,
        chartColors.info,
        chartColors.orange
    ];

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: labels.length ? labels : ['Sembrado', 'Cosecha', 'Aplicacion', 'Riego'],
            datasets: [{
                label: 'Investment ($)',
                data: values.length ? values : [438.5, 285, 160.5, 97],
                backgroundColor: colors,
                borderColor: colors.map(c => c),
                borderWidth: 1
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        callback: value => '$' + value
                    }
                }
            }
        }
    });
}

function renderTasksChart(kpis) {
    const ctx = document.getElementById('tareasChart');
    if (!ctx) return;

    const ops = kpis.operations || {};
    const completed = ops.tasks_completed || 8;
    const pending = (ops.total_tasks || 11) - completed;

    new Chart(ctx, {
        type: 'doughnut',
        data: {
            labels: ['Completed', 'Pending'],
            datasets: [{
                data: [completed, pending],
                backgroundColor: [chartColors.success, chartColors.warning],
                borderWidth: 0
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { position: 'bottom' }
            }
        }
    });
}

function renderTopEmployeesTable(employees) {
    const tbody = document.getElementById('topEmpleados');
    if (!tbody) return;

    const topEmployees = employees.slice(0, 5);

    if (topEmployees.length === 0) {
        tbody.innerHTML = '<tr><td colspan="7" class="text-center">Loading data...</td></tr>';
        return;
    }

    tbody.innerHTML = topEmployees.map(emp => `
        <tr>
            <td>${getRankingIcon(emp.efficiency_rank)}</td>
            <td><strong>${emp.name}</strong></td>
            <td><span class="badge bg-info">${emp.specialty}</span></td>
            <td>${emp.tasks_completed}</td>
            <td>${formatPercentage(emp.success_rate)}</td>
            <td>${formatPercentage(emp.roi_percentage)}</td>
            <td>
                <div class="progress" style="height: 20px;">
                    <div class="progress-bar bg-${getEfficiencyColor(emp.success_rate)}" 
                         style="width: ${emp.success_rate}%">
                        ${formatPercentage(emp.success_rate)}
                    </div>
                </div>
            </td>
        </tr>
    `).join('');
}

// Listen for data loaded event
window.addEventListener('dataLoaded', renderDashboard);

// Also try on DOMContentLoaded with delay
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
        if (window.cultivoData) {
            renderDashboard();
        }
    }, 500);
    setTimeout(function () {
        if (window.cultivoData) {
            renderDashboard();
        }
    }, 1500);
});