-- ADVANCED ANALYTICS QUERIES - RICE CROP SYSTEM

USE Rice_Crop_DB;

-- 1. EMPLOYEE PRODUCTIVITY ANALYSIS
-- Full employee ranking with efficiency metrics
SELECT 
    '=== EMPLOYEE PRODUCTIVITY ANALYSIS ===' as title;

SELECT 
    e.id,
    e.name,
    e.specialty,
    e.daily_salary,
    COUNT(DISTINCT a.task_id) as total_tasks_assigned,
    SUM(a.hours_worked) as total_hours_worked,
    ROUND(AVG(a.hours_worked), 2) as avg_hours_per_task,
    COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) as tasks_completed,
    ROUND(COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) / COUNT(DISTINCT a.task_id) * 100, 2) as success_rate,
    ROUND(SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END), 2) as total_cost_generated,
    ROUND(SUM(a.hours_worked * e.daily_salary / 8), 2) as labor_cost,
    ROUND(
        (SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END) - 
         SUM(a.hours_worked * e.daily_salary / 8)) / 
         NULLIF(SUM(a.hours_worked * e.daily_salary / 8), 0) * 100, 2
    ) as employee_roi_pct,
    RANK() OVER (
        ORDER BY 
            COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) / COUNT(DISTINCT a.task_id) DESC,
            SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END) / SUM(a.hours_worked) DESC
    ) as efficiency_rank
FROM employees e
JOIN assignments a ON e.id = a.employee_id
JOIN tasks t ON a.task_id = t.id
WHERE e.status = 'Active'
GROUP BY e.id, e.name, e.specialty, e.daily_salary
HAVING total_tasks_assigned > 0
ORDER BY efficiency_rank ASC;

-- 2. FINANCIAL ANALYSIS BY ACTIVITY TYPE
SELECT 
    '=== FINANCIAL ANALYSIS BY ACTIVITY TYPE ===' as title;

WITH cost_analysis AS (
    SELECT 
        t.type,
        COUNT(*) as total_tasks,
        COUNT(CASE WHEN t.status = 'Completed' THEN 1 END) as tasks_completed,
        SUM(t.estimated_cost) as total_budget,
        SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END) as total_real_cost,
        AVG(CASE WHEN t.status = 'Completed' THEN t.real_cost END) as avg_real_cost,
        STDDEV(CASE WHEN t.status = 'Completed' THEN t.real_cost - t.estimated_cost END) as cost_variability,
        SUM(CASE WHEN t.real_cost > t.estimated_cost AND t.status = 'Completed' THEN 1 ELSE 0 END) as tasks_over_budget,
        AVG(CASE WHEN t.status = 'Completed' THEN TIMESTAMPDIFF(HOUR, t.start_time, t.end_time) END) as avg_duration_hours
    FROM tasks t
    GROUP BY t.type
),
harvest_revenue AS (
    SELECT 
        'harvest' as type,
        SUM(h.unit_price * h.units_harvested) as total_revenue,
        AVG(h.unit_price * h.units_harvested) as avg_revenue
    FROM harvests h
    JOIN tasks t ON h.task_id = t.id
    WHERE t.status = 'Completed' AND h.unit_price > 0
)
SELECT 
    ca.type,
    ca.total_tasks,
    ca.tasks_completed,
    ROUND(ca.total_real_cost, 2) as total_investment,
    ROUND(ca.avg_real_cost, 2) as avg_cost_per_task,
    ROUND(((ca.total_real_cost - (ca.total_budget * ca.tasks_completed / ca.total_tasks)) / 
           NULLIF(ca.total_budget * ca.tasks_completed / ca.total_tasks, 0)) * 100, 2) as budget_deviation_pct,
    ROUND(ca.cost_variability, 2) as cost_std_dev,
    ROUND((ca.tasks_over_budget * 100.0 / ca.tasks_completed), 1) as pct_tasks_over_budget,
    ROUND(ca.avg_duration_hours, 1) as avg_hours_per_task,
    ROUND(ca.total_real_cost / NULLIF(ca.avg_duration_hours * ca.tasks_completed, 0), 2) as cost_per_hour,
    COALESCE(ROUND(hr.total_revenue, 2), 0) as revenue_generated,
    COALESCE(ROUND((hr.total_revenue - ca.total_real_cost) / NULLIF(ca.total_real_cost, 0) * 100, 2), 0) as roi_pct
FROM cost_analysis ca
LEFT JOIN harvest_revenue hr ON ca.type = hr.type
ORDER BY ca.total_real_cost DESC;

-- 3. TEMPORAL ANALYSIS AND SEASONALITY
SELECT '=== TEMPORAL ANALYSIS AND SEASONALITY ===' as title;

WITH monthly AS (
  SELECT 
    YEAR(t.start_time) AS year,
    MONTH(t.start_time) AS month,
    MONTHNAME(t.start_time) AS month_name,
    t.type AS activity_type,
    COUNT(*) AS tasks_started,
    SUM(CASE WHEN t.status = 'Completed' THEN 1 ELSE 0 END) AS tasks_completed,
    ROUND(AVG(CASE WHEN t.status = 'Completed' THEN t.real_cost END), 2) AS avg_cost,
    ROUND(AVG(CASE WHEN t.status = 'Completed' THEN TIMESTAMPDIFF(HOUR, t.start_time, t.end_time) END), 1) AS avg_duration_hours,
    -- metrics by type
    ROUND(AVG(CASE WHEN t.type = 'harvest' THEN h.units_harvested END), 2) AS metric_harvest_avg,
    ROUND(AVG(CASE WHEN t.type = 'planting' THEN p.seed_kg END), 2) AS metric_planting_avg,
    ROUND(AVG(CASE WHEN t.type = 'irrigation' THEN i.water_liters END), 0) AS metric_irrigation_avg,
    ROUND(AVG(CASE WHEN t.type = 'application' THEN a.liters END), 2) AS metric_application_avg
  FROM tasks t
  LEFT JOIN harvests h ON t.id = h.task_id
  LEFT JOIN planting p ON t.id = p.task_id
  LEFT JOIN irrigation i ON t.id = i.task_id
  LEFT JOIN application a ON t.id = a.task_id
  WHERE t.start_time >= '2024-01-01'
  GROUP BY YEAR(t.start_time), MONTH(t.start_time), MONTHNAME(t.start_time), t.type
)
, with_lag AS (
  SELECT
    m.*,
    LAG(m.tasks_completed) OVER (PARTITION BY m.activity_type ORDER BY m.year, m.month) AS tasks_prev_month
  FROM monthly m
)
SELECT
  year,
  month,
  month_name,
  activity_type,
  tasks_started,
  tasks_completed,
  ROUND(tasks_completed / NULLIF(tasks_started,0) * 100, 1) AS completion_rate,
  avg_cost,
  avg_duration_hours,
  CASE activity_type
    WHEN 'harvest' THEN metric_harvest_avg
    WHEN 'planting' THEN metric_planting_avg
    WHEN 'irrigation' THEN metric_irrigation_avg
    WHEN 'application' THEN metric_application_avg
    ELSE NULL
  END AS technical_metric_avg,
  tasks_prev_month,
  ROUND(
    ( (tasks_completed - tasks_prev_month) * 100.0 ) / NULLIF(tasks_prev_month, 0),
    2
  ) AS monthly_variation_pct
FROM with_lag
ORDER BY year DESC, month DESC, activity_type;

-- 4. PERFORMANCE ANALYSIS BY AREA AND LOCATION
SELECT 
    '=== PERFORMANCE ANALYSIS BY AREA AND LOCATION ===' as title;

WITH area_performance AS (
    SELECT 
        ar.id as area_id,
        ar.name as area_name,
        ar.hectares,
        ar.soil_type,
        l.id as location_id,
        l.name as location_name,
        l.square_meters,
        l.coord_x,
        l.coord_y,
        -- Operational metrics
        COUNT(DISTINCT t.id) as total_tasks,
        COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) as tasks_completed,
        ROUND(AVG(CASE WHEN t.status = 'Completed' THEN TIMESTAMPDIFF(HOUR, t.start_time, t.end_time) END), 1) as avg_hours_per_task,
        -- Financial metrics
        ROUND(SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END), 2) as total_investment,
        ROUND(AVG(CASE WHEN t.status = 'Completed' THEN t.real_cost END), 2) as avg_task_cost,
        -- Productivity metrics
        ROUND(SUM(CASE WHEN t.type = 'harvest' AND t.status = 'Completed' THEN h.units_harvested ELSE 0 END), 2) as total_harvested,
        ROUND(SUM(CASE WHEN t.type = 'harvest' AND t.status = 'Completed' THEN h.kg_equivalent ELSE 0 END), 2) as total_kg,
        ROUND(AVG(CASE WHEN t.type = 'harvest' AND t.status = 'Completed' THEN h.yield_per_hectare END), 2) as avg_yield_hectare,
        ROUND(SUM(CASE WHEN t.type = 'harvest' AND t.status = 'Completed' THEN h.unit_price * h.units_harvested ELSE 0 END), 2) as total_revenue
    FROM areas ar
    JOIN locations l ON ar.id = l.area_id AND l.active = TRUE
    LEFT JOIN tasks t ON l.id = t.location_id
    LEFT JOIN harvests h ON t.id = h.task_id
    GROUP BY ar.id, ar.name, ar.hectares, ar.soil_type, l.id, l.name, l.square_meters, l.coord_x, l.coord_y
    HAVING total_tasks > 0
)
SELECT 
    ap.area_name,
    ap.location_name,
    ap.hectares,
    ap.soil_type,
    ap.total_tasks,
    ap.tasks_completed,
    ap.total_investment,
    ap.total_revenue,
    ROUND(ap.total_revenue - ap.total_investment, 2) as net_profit,
    CASE 
        WHEN ap.total_investment > 0 THEN ROUND((ap.total_revenue - ap.total_investment) / ap.total_investment * 100, 2)
        ELSE NULL 
    END as roi_pct,
    ap.total_harvested,
    ap.avg_yield_hectare,
    -- Rankings
    DENSE_RANK() OVER (ORDER BY ap.avg_yield_hectare DESC) as productivity_rank,
    DENSE_RANK() OVER (ORDER BY (ap.total_revenue - ap.total_investment) DESC) as profitability_rank,
    -- Comparative indices
    ROUND(CASE 
        WHEN ap.avg_yield_hectare IS NOT NULL THEN 
            ap.avg_yield_hectare / 
            NULLIF((SELECT AVG(avg_yield_hectare) FROM area_performance WHERE avg_yield_hectare IS NOT NULL), 0) * 100
        ELSE NULL 
    END, 1) as productivity_index
FROM area_performance ap
WHERE ap.tasks_completed > 0
ORDER BY ap.avg_yield_hectare DESC, (ap.total_revenue - ap.total_investment) DESC;

-- 5. PREDICTIVE INSIGHTS AND RECOMMENDATIONS
SELECT '=== INSIGHTS AND STRATEGIC RECOMMENDATIONS ===' as title;

WITH
best_employee AS (
  SELECT 
    CONCAT(e.name, ' (', e.specialty, ')') AS value,
    CONCAT('Efficiency: ', ROUND(COUNT(CASE WHEN t.status = 'Completed' THEN 1 END) / COUNT(*) * 100, 1), '%') AS metric,
    'Consider for promotion to supervisor or team lead' AS recommendation,
    ROW_NUMBER() OVER (
      ORDER BY (COUNT(CASE WHEN t.status = 'Completed' THEN 1 END) / COUNT(*)) DESC,
               SUM(CASE WHEN t.status = 'Completed' THEN t.real_cost ELSE 0 END) / NULLIF(SUM(a.hours_worked),0) DESC
    ) AS rn
  FROM employees e
  JOIN assignments a ON e.id = a.employee_id
  JOIN tasks t ON a.task_id = t.id
  WHERE e.status = 'Active'
  GROUP BY e.id, e.name, e.specialty
  HAVING COUNT(*) >= 2
),
most_profitable_area AS (
  SELECT 
    ar.name AS value,
    CONCAT('ROI: ', ROUND((SUM(COALESCE(h.unit_price * h.units_harvested,0)) - SUM(t.real_cost)) / NULLIF(SUM(t.real_cost),0) * 100, 1), '%') AS metric,
    'Expand operations and replicate best practices' AS recommendation,
    ROW_NUMBER() OVER (ORDER BY (SUM(COALESCE(h.unit_price * h.units_harvested,0)) - SUM(t.real_cost)) / NULLIF(SUM(t.real_cost),0) DESC) AS rn
  FROM areas ar
  JOIN tasks t ON ar.id = t.area_id AND t.status = 'Completed'
  LEFT JOIN harvests h ON t.id = h.task_id
  GROUP BY ar.id, ar.name
  HAVING SUM(t.real_cost) > 0 AND SUM(COALESCE(h.unit_price * h.units_harvested,0)) > 0
),
most_expensive_activity AS (
  SELECT 
    UPPER(t.type) AS value,
    CONCAT('Average: $', ROUND(AVG(t.real_cost), 2)) AS metric,
    'Review processes and seek cost optimizations' AS recommendation,
    ROW_NUMBER() OVER (ORDER BY AVG(t.real_cost) DESC) AS rn
  FROM tasks t
  WHERE t.status = 'Completed' AND t.real_cost > 0
  GROUP BY t.type
),
best_variety AS (
  SELECT 
    COALESCE(p.variety, 'Insufficient Data') AS value,
    CONCAT('Yield: ', ROUND(AVG(h.yield_per_hectare), 2), ' kg/ha') AS metric,
    'Prioritize this variety in future plantings' AS recommendation,
    ROW_NUMBER() OVER (ORDER BY AVG(h.yield_per_hectare) DESC) AS rn
  FROM planting p
  JOIN tasks t ON p.task_id = t.id AND t.status = 'Completed'
  JOIN tasks t2 ON t.area_id = t2.area_id AND t2.type = 'harvest' AND t2.status = 'Completed'
  JOIN harvests h ON t2.id = h.task_id
  WHERE h.yield_per_hectare > 0
  GROUP BY p.variety
  HAVING COUNT(*) >= 1
)
SELECT 'BEST EMPLOYEE' AS category, value, metric, recommendation FROM best_employee WHERE rn = 1
UNION ALL
SELECT 'MOST PROFITABLE AREA' AS category, value, metric, recommendation FROM most_profitable_area WHERE rn = 1
UNION ALL
SELECT 'MOST EXPENSIVE ACTIVITY' AS category, value, metric, recommendation FROM most_expensive_activity WHERE rn = 1
UNION ALL
SELECT 'BEST RICE VARIETY' AS category, value, metric, recommendation FROM best_variety WHERE rn = 1;

-- 6. EXECUTIVE DASHBOARD - KEY METRICS (KPIs)
SELECT 
    '=== EXECUTIVE DASHBOARD - KEY KPIS ===' as title;

-- Operational KPIs
SELECT 
    'OPERATIONS' as category,
    COUNT(DISTINCT e.id) as active_employees,
    COUNT(DISTINCT CASE WHEN e.specialty != 'General' THEN e.id END) as specialized_employees,
    COUNT(DISTINCT ar.id) as productive_areas,
    COUNT(DISTINCT l.id) as active_locations,
    COUNT(DISTINCT t.id) as total_tasks,
    COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) as completed_tasks,
    ROUND(COUNT(DISTINCT CASE WHEN t.status = 'Completed' THEN t.id END) / COUNT(DISTINCT t.id) * 100, 1) as completion_pct
FROM employees e
CROSS JOIN areas ar
CROSS JOIN locations l
CROSS JOIN tasks t
WHERE e.status = 'Active' AND l.active = TRUE;

-- Financial KPIs
SELECT 
    'FINANCE' as category,
    ROUND(SUM(t.real_cost), 2) as total_investment,
    ROUND(AVG(t.real_cost), 2) as avg_task_cost,
    ROUND(SUM(CASE WHEN h.unit_price > 0 THEN h.unit_price * h.units_harvested ELSE 0 END), 2) as harvest_revenue,
    ROUND(SUM(CASE WHEN h.unit_price > 0 THEN h.unit_price * h.units_harvested ELSE 0 END) - SUM(t.real_cost), 2) as net_profit,
    ROUND(((SUM(CASE WHEN h.unit_price > 0 THEN h.unit_price * h.units_harvested ELSE 0 END) - SUM(t.real_cost)) / SUM(t.real_cost)) * 100, 2) as roi_pct,
    ROUND(SUM(t.real_cost) / SUM(ar.hectareas), 2) as investment_per_hectare
FROM tasks t
LEFT JOIN harvests h ON t.id = h.task_id
LEFT JOIN areas ar ON t.area_id = ar.id
WHERE t.status = 'Completed';

-- Productivity KPIs
SELECT 
    'PRODUCTIVITY' as category,
    ROUND(SUM(h.units_harvested), 2) as total_harvested_units,
    ROUND(SUM(h.kg_equivalent), 2) as total_kg_produced,
    ROUND(AVG(h.yield_per_hectare), 2) as avg_yield_hectare,
    COUNT(DISTINCT h.task_id) as harvests_completed,
    ROUND(AVG(h.humidity_pct), 1) as avg_humidity,
    COUNT(CASE WHEN h.quality = 'First' THEN 1 END) as first_quality_harvests,
    ROUND(COUNT(CASE WHEN h.quality = 'First' THEN 1 END) / COUNT(*) * 100, 1) as first_quality_pct
FROM harvests h
JOIN tasks t ON h.task_id = t.id AND t.status = 'Completed';

-- 7. CONSOLIDATED VIEW FOR DATA EXPORT
SELECT 
    '=== PREPARING VIEW FOR CSV/EXCEL EXPORT ===' as title;

CREATE OR REPLACE VIEW full_data_view AS
SELECT 
    -- IDs and Dates
    t.id as task_id,
    DATE(t.start_time) as start_date,
    TIME(t.start_time) as start_time,
    DATE(t.end_time) as end_date,
    TIME(t.end_time) as end_time,
    TIMESTAMPDIFF(HOUR, t.start_time, t.end_time) as duration_hours,
    DAYNAME(t.start_time) as day_of_week,
    MONTH(t.start_time) as month,
    YEAR(t.start_time) as year,
    
    -- Task Info
    t.type as activity_type,
    t.status,
    t.priority,
    t.description,
    t.estimated_cost,
    t.real_cost,
    t.real_cost - t.estimated_cost as cost_deviation,
    CASE 
        WHEN t.estimated_cost > 0 THEN ROUND((t.real_cost - t.estimated_cost) / t.estimated_cost * 100, 2)
        ELSE NULL 
    END as pct_deviation,
    
    -- Geographical Info
    ar.id as area_id,
    ar.name as area_name,
    ar.hectares,
    ar.soil_type,
    l.id as location_id,
    l.name as location_name,
    l.square_meters,
    ROUND(l.coord_x, 6) as coord_x,
    ROUND(l.coord_y, 6) as coord_y,
    
    -- Employee Info
    e.id as employee_id,
    e.name as employee_name,
    e.specialty as employee_specialty,
    e.daily_salary,
    a.hours_worked,
    a.role,
    ROUND(a.hours_worked * e.daily_salary / 8, 2) as labor_cost,
    
    -- Specific Activity Data
    CASE WHEN t.type = 'planting' THEN p.variety END as grain_variety,
    CASE WHEN t.type = 'planting' THEN p.seed_kg END as seed_kg,
    CASE WHEN t.type = 'planting' THEN p.sowing_density END as sowing_density,
    CASE WHEN t.type = 'planting' THEN p.method END as sowing_method,
    
    CASE WHEN t.type = 'application' THEN app.product END as product_applied,
    CASE WHEN t.type = 'application' THEN app.type END as products_type,
    CASE WHEN t.type = 'application' THEN app.liters END as liters_applied,
    CASE WHEN t.type = 'application' THEN app.cost_per_liter END as cost_per_liter,
    CASE WHEN t.type = 'application' THEN app.weather_condition END as weather_conditions,
    
    CASE WHEN t.type = 'irrigation' THEN i.water_liters END as water_liters,
    CASE WHEN t.type = 'irrigation' THEN i.gas_tanks END as gas_tanks,
    CASE WHEN t.type = 'irrigation' THEN i.fuel_cost END as fuel_cost,
    CASE WHEN t.type = 'irrigation' THEN i.duration_minutes END as irrigation_minutes,
    CASE WHEN t.type = 'irrigation' THEN i.method END as irrigation_method,
    
    CASE WHEN t.type = 'harvest' THEN h.units_harvested END as units_harvested,
    CASE WHEN t.type = 'harvest' THEN h.kg_equivalent END as kg_harvested,
    CASE WHEN t.type = 'harvest' THEN h.yield_per_hectare END as yield_per_hectare,
    CASE WHEN t.type = 'harvest' THEN h.quality END as harvest_quality,
    CASE WHEN t.type = 'harvest' THEN h.unit_price END as unit_price,
    CASE WHEN t.type = 'harvest' THEN h.unit_price * h.units_harvested END as gross_revenue,
    CASE WHEN t.type = 'harvest' THEN (h.unit_price * h.units_harvested) - t.real_cost END as net_profit
    
FROM tasks t
JOIN areas ar ON t.area_id = ar.id
JOIN locations l ON t.location_id = l.id
JOIN assignments a ON t.id = a.task_id
JOIN employees e ON a.employee_id = e.id
LEFT JOIN planting p ON t.id = p.task_id
LEFT JOIN application app ON t.id = app.task_id
LEFT JOIN irrigation i ON t.id = i.task_id
LEFT JOIN harvests h ON t.id = h.task_id;

-- Final Sample Query
SELECT 
    'SAMPLE EXPORT DATA (first 10 records):' as info;

SELECT * FROM full_data_view 
ORDER BY start_date DESC, task_id DESC
LIMIT 10;
