/**
 * Rice Crop Analytics - Finanzas Page Module
 * Renders financial analysis charts and tables
 */

let finanzasRendered = false;

function renderFinanzasPage() {
    if (finanzasRendered) return;

    const financial = window.cultivoData.financial || [];
    const trends = window.cultivoData.trends || [];

    if (financial.length === 0) {
        console.log('No financial data available');
        return;
    }

    finanzasRendered = true;
    console.log('Rendering finanzas:', financial.length);

    loadFinanzasData(financial);
    createCostAnalysisChart(financial);
    createTrendsChart(trends);
}

function loadFinanzasData(financial) {
    const tableBody = document.getElementById('financialTableBody');
    if (!tableBody) return;

    let html = '';
    financial.forEach(item => {
        const completionRate = item.tasks_completed / item.total_tasks * 100 || 0;
        const statusClass = item.roi_percentage > 100 ? 'success' : item.roi_percentage > 0 ? 'primary' : 'danger';
        const statusText = item.roi_percentage > 100 ? 'Excellent' : item.roi_percentage > 0 ? 'Positive' : 'Negative';

        html += `
            <tr>
                <td><span class="badge bg-secondary">${capitalize(item.activity_type)}</span></td>
                <td class="text-center">${item.total_tasks}</td>
                <td class="text-center">
                    <div class="d-flex align-items-center">
                        <span class="me-2">${item.tasks_completed}</span>
                        <div class="progress flex-grow-1" style="height: 6px;">
                            <div class="progress-bar bg-success" style="width: ${completionRate}%"></div>
                        </div>
                    </div>
                </td>
                <td class="fw-bold text-primary">${formatCurrency(item.total_investment)}</td>
                <td>${formatCurrency(item.avg_cost_per_task)}</td>
                <td class="${item.budget_deviation_pct < 0 ? 'text-success' : 'text-danger'}">
                    ${formatPercentage(item.budget_deviation_pct)}
                </td>
                <td class="text-center">${formatNumber(item.avg_hours_per_task, 1)}h</td>
                <td>${formatCurrency(item.cost_per_hour)}</td>
                <td class="fw-bold ${item.roi_percentage > 0 ? 'text-success' : 'text-danger'}">
                    ${formatPercentage(item.roi_percentage)}
                </td>
                <td>
                    <span class="badge bg-${statusClass}">${statusText}</span>
                </td>
            </tr>
        `;
    });

    tableBody.innerHTML = html;
}

function capitalize(str) {
    if (!str) return '';
    return str.charAt(0).toUpperCase() + str.slice(1);
}

function createCostAnalysisChart(financial) {
    const ctx = document.getElementById('costosChart');
    if (!ctx) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: financial.map(item => capitalize(item.activity_type)),
            datasets: [
                {
                    label: 'Total Investment',
                    data: financial.map(item => item.total_investment),
                    backgroundColor: chartColors.primary,
                    borderWidth: 1
                },
                {
                    label: 'Revenue Generated',
                    data: financial.map(item => item.revenue_generated),
                    backgroundColor: chartColors.success,
                    borderWidth: 1
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Investment vs Revenue by Activity'
                },
                legend: { position: 'top' }
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

function createTrendsChart(trends) {
    const ctx = document.getElementById('tendenciasChart');
    if (!ctx || trends.length === 0) return;

    const filteredTrends = trends
        .filter(item => item.avg_cost !== null && item.avg_cost > 0)
        .sort((a, b) => (a.year * 100 + a.month) - (b.year * 100 + b.month));

    const activities = [...new Set(filteredTrends.map(item => item.activity_type))];
    const colors = [chartColors.primary, chartColors.success, chartColors.warning, chartColors.danger];

    const datasets = activities.map((activity, index) => {
        const data = filteredTrends
            .filter(item => item.activity_type === activity)
            .map(item => ({
                x: `${item.year}-${String(item.month).padStart(2, '0')}`,
                y: item.avg_cost
            }));

        return {
            label: capitalize(activity),
            data: data,
            borderColor: colors[index % colors.length],
            backgroundColor: colors[index % colors.length] + '20',
            borderWidth: 2,
            fill: false,
            tension: 0.4
        };
    });

    new Chart(ctx, {
        type: 'line',
        data: { datasets: datasets },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Monthly Cost Trends'
                },
                legend: { position: 'top' }
            },
            scales: {
                x: {
                    type: 'category',
                    title: { display: true, text: 'Month' }
                },
                y: {
                    beginAtZero: true,
                    title: { display: true, text: 'Average Cost ($)' },
                    ticks: {
                        callback: value => '$' + value
                    }
                }
            }
        }
    });
}

function exportFinancialData() {
    const financial = window.cultivoData.financial || [];
    if (financial.length === 0) return;

    const headers = ['Activity Type', 'Total Tasks', 'Completed', 'Total Investment', 'Avg Cost', 'Deviation %', 'Avg Hours', 'Cost/Hour', 'ROI %', 'Status'];
    let csv = [headers.join(',')];

    financial.forEach(item => {
        const row = [
            capitalize(item.activity_type),
            item.total_tasks,
            item.tasks_completed,
            item.total_investment,
            item.avg_cost_per_task,
            item.budget_deviation_pct,
            item.avg_hours_per_task,
            item.cost_per_hour,
            item.roi_percentage,
            item.roi_percentage > 0 ? 'Positive' : 'Negative'
        ];
        csv.push(row.map(cell => `"${cell}"`).join(','));
    });

    downloadCSV(csv.join('\n'), 'financial-analysis.csv');
}

// Listen for data loaded event
window.addEventListener('dataLoaded', renderFinanzasPage);

// Also try on DOMContentLoaded with delay
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.financial && window.cultivoData.financial.length > 0) {
            renderFinanzasPage();
        }
    }, 500);
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.financial && window.cultivoData.financial.length > 0) {
            renderFinanzasPage();
        }
    }, 1500);
});

// Fallback
if (window.cultivoData && window.cultivoData.financial && window.cultivoData.financial.length > 0) {
    renderFinanzasPage();
}

// Export function for button
window.exportFinancialData = exportFinancialData;