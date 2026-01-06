/**
 * Rice Crop Analytics - Areas Page Module
 * Renders area performance chart and table
 */

let areasRendered = false;

function renderAreasPage() {
    if (areasRendered) return;

    const areas = window.cultivoData.areas || [];

    if (areas.length === 0) {
        console.log('No areas data available');
        return;
    }

    areasRendered = true;
    console.log('Rendering areas:', areas.length);

    loadAreasData(areas);
    createScatterChart(areas);
}

function loadAreasData(areas) {
    const tableBody = document.getElementById('areasTableBody');
    if (!tableBody) return;

    let html = '';
    areas.forEach(area => {
        const roiClass = area.roi_percentage > 0 ? 'text-success' : 'text-danger';
        const statusClass = area.roi_percentage > 100 ? 'success' : area.roi_percentage > 0 ? 'primary' : 'danger';
        const statusText = area.roi_percentage > 100 ? 'Excellent' : area.roi_percentage > 0 ? 'Positive' : 'Critical';
        const completionPct = area.total_tasks > 0 ? (area.tasks_completed / area.total_tasks) * 100 : 0;

        html += `
            <tr>
                <td>${getRankingIcon(area.profitability_rank)}</td>
                <td>
                    <strong>${area.area_name}</strong><br>
                    <small class="text-muted">Rank: #${area.productivity_rank}</small>
                </td>
                <td>${area.location_name}</td>
                <td class="text-center">${formatNumber(area.hectares, 1)} ha</td>
                <td><span class="badge bg-brown">${area.soil_type}</span></td>
                <td class="text-center">
                    ${area.tasks_completed}/${area.total_tasks}
                    <div class="progress mt-1" style="height: 4px;">
                        <div class="progress-bar bg-success" style="width: ${completionPct}%"></div>
                    </div>
                </td>
                <td class="fw-bold text-primary">${formatCurrency(area.total_investment)}</td>
                <td class="fw-bold text-success">${formatCurrency(area.total_revenue)}</td>
                <td class="fw-bold ${roiClass}">${formatPercentage(area.roi_percentage)}</td>
                <td class="text-center">
                    ${area.total_torvadas > 0 ? formatNumber(area.total_torvadas, 1) : '0'}
                </td>
                <td>
                    <span class="badge bg-${statusClass}">${statusText}</span>
                </td>
            </tr>
        `;
    });

    tableBody.innerHTML = html;
}

function createScatterChart(areas) {
    const ctx = document.getElementById('scatterChart');
    if (!ctx) return;

    const data = areas.map(area => ({
        x: area.total_investment,
        y: area.total_torvadas || 0,
        label: `${area.area_name} - ${area.location_name}`,
        roi: area.roi_percentage
    }));

    new Chart(ctx, {
        type: 'scatter',
        data: {
            datasets: [{
                label: 'Performance vs Investment',
                data: data,
                backgroundColor: data.map(point => {
                    if (point.roi > 100) return chartColors.success + '80';
                    if (point.roi > 0) return chartColors.primary + '80';
                    return chartColors.danger + '80';
                }),
                borderColor: data.map(point => {
                    if (point.roi > 100) return chartColors.success;
                    if (point.roi > 0) return chartColors.primary;
                    return chartColors.danger;
                }),
                borderWidth: 2,
                pointRadius: 8
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                title: {
                    display: true,
                    text: 'Performance vs Investment by Area'
                },
                legend: { display: false },
                tooltip: {
                    callbacks: {
                        label: function (context) {
                            const point = data[context.dataIndex];
                            return [
                                point.label,
                                `Investment: ${formatCurrency(point.x)}`,
                                `Harvested: ${point.y}`,
                                `ROI: ${formatPercentage(point.roi)}`
                            ];
                        }
                    }
                }
            },
            scales: {
                x: {
                    title: { display: true, text: 'Total Investment ($)' },
                    ticks: {
                        callback: value => '$' + value
                    }
                },
                y: {
                    title: { display: true, text: 'Units Harvested' },
                    beginAtZero: true
                }
            }
        }
    });
}

function filterByROI(type) {
    const rows = document.querySelectorAll('#areasTableBody tr');

    rows.forEach(row => {
        const roiCell = row.cells[8];
        const roiText = roiCell.textContent.trim();
        const roiValue = parseFloat(roiText.replace('%', ''));

        let showRow = true;

        switch (type) {
            case 'positive':
                showRow = roiValue > 0;
                break;
            case 'negative':
                showRow = roiValue <= 0;
                break;
            default:
                showRow = true;
        }

        row.style.display = showRow ? '' : 'none';
    });
}

function exportAreasData() {
    const areas = window.cultivoData.areas || [];
    if (areas.length === 0) return;

    const headers = ['Ranking', 'Area', 'Location', 'Hectares', 'Soil Type', 'Tasks', 'Investment', 'Revenue', 'ROI %', 'Harvested', 'Status'];
    let csv = [headers.join(',')];

    areas.forEach(area => {
        const row = [
            area.profitability_rank,
            area.area_name,
            area.location_name,
            area.hectares,
            area.soil_type,
            `${area.tasks_completed}/${area.total_tasks}`,
            area.total_investment,
            area.total_revenue,
            area.roi_percentage,
            area.total_torvadas || 0,
            area.roi_percentage > 0 ? 'Positive' : 'Critical'
        ];
        csv.push(row.map(cell => `"${cell}"`).join(','));
    });

    downloadCSV(csv.join('\n'), 'area-performance.csv');
}

// Listen for data loaded event
window.addEventListener('dataLoaded', renderAreasPage);

// Also try on DOMContentLoaded with delay
document.addEventListener('DOMContentLoaded', function () {
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.areas && window.cultivoData.areas.length > 0) {
            renderAreasPage();
        }
    }, 500);
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.areas && window.cultivoData.areas.length > 0) {
            renderAreasPage();
        }
    }, 1500);
});

// Export functions
window.filterByROI = filterByROI;
window.exportAreasData = exportAreasData;