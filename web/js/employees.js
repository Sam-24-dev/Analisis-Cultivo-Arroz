/**
 * Rice Crop Analytics - Employees Page Module
 * Renders employee productivity chart and table
 */

let employeesRendered = false;

function renderEmpleadosPage() {
    if (employeesRendered) return;

    const employees = window.cultivoData.employees || [];

    if (employees.length === 0) {
        console.log('No employee data available');
        return;
    }

    employeesRendered = true;
    console.log('Rendering employees:', employees.length);

    loadEmpleadosData(employees);
    createEmpleadosChart(employees);
}

function loadEmpleadosData(employees) {
    const tableBody = document.getElementById('empleadosTableBody');
    if (!tableBody) return;

    let html = '';
    employees.forEach(emp => {
        const roiValue = emp.roi_percentage;
        const roiDisplay = roiValue ? formatPercentage(roiValue) : 'N/A';
        const statusClass = emp.tasks_completed > 0 ? 'success' : 'secondary';
        const statusText = emp.tasks_completed > 0 ? 'Active' : 'Inactive';

        html += `
            <tr>
                <td>${getRankingIcon(emp.efficiency_rank)}</td>
                <td>
                    <div class="d-flex align-items-center">
                        <div class="status-indicator status-${emp.tasks_completed > 0 ? 'active' : 'inactive'}"></div>
                        <div>
                            <strong>${emp.name}</strong><br>
                            <small class="text-muted">ID: ${emp.id}</small>
                        </div>
                    </div>
                </td>
                <td>${emp.id}</td>
                <td><span class="badge bg-primary">${emp.specialty}</span></td>
                <td>${formatCurrency(emp.daily_salary)}</td>
                <td class="text-center">${emp.total_tasks}</td>
                <td class="text-center">${formatNumber(emp.hours_worked)}</td>
                <td>
                    <div class="d-flex align-items-center">
                        <span class="me-2">${formatPercentage(emp.success_rate)}</span>
                        <div class="progress flex-grow-1" style="height: 6px;">
                            <div class="progress-bar bg-${getEfficiencyColor(emp.success_rate)}" 
                                 style="width: ${emp.success_rate}%"></div>
                        </div>
                    </div>
                </td>
                <td class="fw-bold ${roiValue && roiValue > 200 ? 'text-success' : roiValue && roiValue > 100 ? 'text-primary' : 'text-warning'}">
                    ${roiDisplay}
                </td>
                <td>
                    <span class="badge bg-${getEfficiencyColor(emp.success_rate)}">
                        ${statusText}
                    </span>
                </td>
            </tr>
        `;
    });

    tableBody.innerHTML = html;
}

function createEmpleadosChart(employees) {
    const ctx = document.getElementById('empleadosChart');
    if (!ctx) return;

    const filteredEmps = employees
        .filter(emp => emp.roi_percentage !== null && emp.roi_percentage !== 0)
        .sort((a, b) => b.roi_percentage - a.roi_percentage);

    if (filteredEmps.length === 0) return;

    new Chart(ctx, {
        type: 'bar',
        data: {
            labels: filteredEmps.map(emp => emp.name.split(' ')[0]),
            datasets: [{
                label: 'ROI by Employee (%)',
                data: filteredEmps.map(emp => emp.roi_percentage),
                backgroundColor: filteredEmps.map(emp => {
                    const roi = emp.roi_percentage;
                    if (roi > 500) return chartColors.success;
                    if (roi > 200) return chartColors.primary;
                    if (roi > 100) return chartColors.warning;
                    return chartColors.danger;
                }),
                borderWidth: 1
            }]
        },
        options: {
            indexAxis: 'y',
            responsive: true,
            maintainAspectRatio: false,
            plugins: {
                legend: { display: false }
            },
            scales: {
                x: {
                    beginAtZero: true,
                    ticks: {
                        callback: value => value + '%'
                    }
                }
            }
        }
    });
}

function exportEmpleadosCSV() {
    const employees = window.cultivoData.employees || [];
    if (employees.length === 0) return;

    const headers = ['Ranking', 'Name', 'ID', 'Specialty', 'Daily Salary', 'Tasks Assigned', 'Hours Worked', 'Success Rate', 'ROI %', 'Status'];
    let csv = [headers.join(',')];

    employees.forEach(emp => {
        const row = [
            emp.efficiency_rank,
            emp.name,
            emp.id,
            emp.specialty,
            emp.daily_salary,
            emp.total_tasks,
            emp.hours_worked,
            emp.success_rate,
            emp.roi_percentage || 'N/A',
            emp.tasks_completed > 0 ? 'Active' : 'Inactive'
        ];
        csv.push(row.map(cell => `"${cell}"`).join(','));
    });

    downloadCSV(csv.join('\n'), 'employees-productivity.csv');
}

// Listen for data loaded event
window.addEventListener('dataLoaded', renderEmpleadosPage);

// Also try on DOMContentLoaded with a small delay
document.addEventListener('DOMContentLoaded', function () {
    // Try immediately
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.employees && window.cultivoData.employees.length > 0) {
            renderEmpleadosPage();
        }
    }, 500);

    // Try again after 1 second in case data is slow
    setTimeout(function () {
        if (window.cultivoData && window.cultivoData.employees && window.cultivoData.employees.length > 0) {
            renderEmpleadosPage();
        }
    }, 1500);
});

// Export function for button
window.exportTableToCSV = exportEmpleadosCSV;