/**
 * Rice Crop Analytics - Insights Page Module
 * Renders insights, recommendations, and trend charts
 */

let insightsRendered = false;

function renderInsightsPage() {
    if (insightsRendered) return;

    const recommendations = window.cultivoData.recommendations || [];
    const trends = window.cultivoData.trends || [];

    // Only require trends for rendering (recommendations may be empty)
    if (trends.length === 0 && recommendations.length === 0) {
        console.log('No insights data available');
        return;
    }

    insightsRendered = true;
    console.log('Rendering insights');

    updateRecommendationCards(recommendations);
    createTrendsChart(trends);
}

function updateRecommendationCards(recommendations) {
    if (recommendations.length === 0) return;

    // Best Employee Card
    const bestEmployee = recommendations.find(r => r.category === 'MEJOR EMPLEADO');
    if (bestEmployee) {
        const card = document.querySelector('.recommendation-card.best-employee');
        if (card) {
            const h4 = card.querySelector('h4');
            if (h4) h4.textContent = bestEmployee.value.split(' (')[0];

            const specialty = card.querySelector('.text-muted');
            if (specialty && bestEmployee.value.includes('(')) {
                specialty.textContent = 'Specialty: ' + bestEmployee.value.split('(')[1].replace(')', '');
            }
        }
    }

    // Best Area Card
    const bestArea = recommendations.find(r => r.category === 'ÁREA MÁS RENTABLE');
    if (bestArea) {
        const card = document.querySelector('.recommendation-card.best-area');
        if (card) {
            const h4 = card.querySelector('h4');
            if (h4) h4.textContent = bestArea.value;

            const badge = card.querySelector('.badge');
            if (badge) badge.textContent = bestArea.metric;
        }
    }

    // Cost Alert Card  
    const costAlert = recommendations.find(r => r.category === 'ACTIVIDAD MÁS COSTOSA');
    if (costAlert) {
        const card = document.querySelector('.recommendation-card.cost-alert');
        if (card) {
            const h4 = card.querySelector('h4');
            if (h4) h4.textContent = costAlert.value;

            const metric = card.querySelector('.text-muted');
            if (metric) metric.textContent = costAlert.metric;
        }
    }
}

function createTrendsChart(trends) {
    const ctx = document.getElementById('trendsChart');
    if (!ctx || trends.length === 0) return;

    // Group data by month
    const monthlyData = {};

    trends.forEach(item => {
        const monthKey = item.month_name || `Month ${item.month}`;
        if (!monthlyData[monthKey]) {
            monthlyData[monthKey] = {
                completed: 0,
                total: 0,
                cost: 0
            };
        }

        monthlyData[monthKey].completed += item.tasks_completed || 0;
        monthlyData[monthKey].total += item.tasks_started || 0;
        monthlyData[monthKey].cost += item.avg_cost || 0;
    });

    const months = Object.keys(monthlyData);
    const completionRates = months.map(month => {
        const data = monthlyData[month];
        return data.total > 0 ? (data.completed / data.total) * 100 : 0;
    });
    const costs = months.map(month => monthlyData[month].cost);

    new Chart(ctx, {
        type: 'line',
        data: {
            labels: months,
            datasets: [
                {
                    label: 'Completion Rate (%)',
                    data: completionRates,
                    borderColor: chartColors.success,
                    backgroundColor: chartColors.success + '20',
                    borderWidth: 3,
                    fill: true,
                    tension: 0.4,
                    yAxisID: 'y'
                },
                {
                    label: 'Average Cost ($)',
                    data: costs,
                    borderColor: chartColors.warning,
                    backgroundColor: chartColors.warning + '20',
                    borderWidth: 3,
                    fill: false,
                    tension: 0.4,
                    yAxisID: 'y1'
                }
            ]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Performance and Cost Trends'
                },
                legend: { position: 'top' }
            },
            scales: {
                y: {
                    type: 'linear',
                    display: true,
                    position: 'left',
                    beginAtZero: true,
                    max: 100,
                    title: { display: true, text: 'Completion Rate (%)' }
                },
                y1: {
                    type: 'linear',
                    display: true,
                    position: 'right',
                    beginAtZero: true,
                    title: { display: true, text: 'Average Cost ($)' },
                    grid: { drawOnChartArea: false },
                    ticks: {
                        callback: value => '$' + value
                    }
                }
            }
        }
    });
}

// Listen for data loaded event
window.addEventListener('dataLoaded', renderInsightsPage);

// Also try on DOMContentLoaded with delay
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
        if (window.cultivoData && (window.cultivoData.trends || window.cultivoData.recommendations)) {
            renderInsightsPage();
        }
    }, 500);
    setTimeout(function () {
        if (window.cultivoData && (window.cultivoData.trends || window.cultivoData.recommendations)) {
            renderInsightsPage();
        }
    }, 1500);
});