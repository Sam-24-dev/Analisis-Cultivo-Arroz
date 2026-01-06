"""
Rice Crop Analytics - ETL Pipeline
Extracts data, transforms into KPIs, and loads to JSON for web dashboard.

Author: Samir Caizapasto
"""

import json
import csv
from pathlib import Path
from datetime import datetime

# Paths
BASE_DIR = Path(__file__).parent.parent
DATA_RAW = BASE_DIR / "data" / "raw"
DATA_PROCESSED = BASE_DIR / "data" / "processed"
WEB_DATA = BASE_DIR / "web" / "data"

# Translation mappings (Spanish to English)
SPECIALTIES = {
    'Aplicacion': 'Application',
    'Sembrado': 'Planting',
    'Supervisor': 'Supervisor',
    'Cosecha': 'Harvest',
    'Riego': 'Irrigation',
    'General': 'General'
}

ACTIVITY_TYPES = {
    'sembrado': 'Planting',
    'aplicacion': 'Application',
    'cosecha': 'Harvest',
    'riego': 'Irrigation'
}

SOIL_TYPES = {
    'franco': 'Loam',
    'arcilloso': 'Clay',
    'limoso': 'Silt',
    'arenoso': 'Sandy'
}

MONTHS = {
    'Enero': 'January', 'Febrero': 'February', 'Marzo': 'March',
    'Abril': 'April', 'Mayo': 'May', 'Junio': 'June',
    'Julio': 'July', 'Agosto': 'August', 'Septiembre': 'September',
    'Octubre': 'October', 'Noviembre': 'November', 'Diciembre': 'December'
}


def translate(value, mapping):
    """Translate a value using the provided mapping."""
    if not value:
        return value
    return mapping.get(value, mapping.get(value.lower(), value))


def load_csv(filename):
    """Load CSV file and return list of dicts."""
    filepath = DATA_RAW / filename
    if not filepath.exists():
        return []
    
    with open(filepath, 'r', encoding='utf-8') as f:
        reader = csv.DictReader(f)
        return list(reader)


def extract_data():
    """Extract raw data from CSV files."""
    print("Extracting data from CSV files...")
    
    data = {
        'financial': load_csv('financial_analysis.csv'),
        'employees': load_csv('employee_productivity.csv'),
        'areas': load_csv('area_performance.csv'),
        'trends': load_csv('temporal_trends.csv'),
        'kpis_finance': load_csv('kpis_finance.csv'),
        'kpis_operations': load_csv('kpis_operations.csv'),
        'kpis_productivity': load_csv('kpis_productivity.csv'),
        'recommendations': load_csv('recommendations.csv'),
        'complete_data': load_csv('full_data_view.csv')
    }
    
    for key, value in data.items():
        print(f"  Loaded {key}: {len(value)} records")
    
    return data


def parse_number(value, default=0):
    """Parse string to number, handling None and empty strings."""
    if value is None or value == '' or value == 'NULL':
        return default
    try:
        if '.' in str(value):
            return float(value)
        return int(value)
    except (ValueError, TypeError):
        return default


def transform_employees(raw_data):
    """Transform employee data into structured format."""
    print("Transforming employee data...")
    
    employees = []
    for row in raw_data.get('employees', []):
        employees.append({
            'id': row.get('cedula', ''),
            'name': row.get('nombre', ''),
            'specialty': translate(row.get('especialidad', ''), SPECIALTIES),
            'daily_salary': parse_number(row.get('salario_diario')),
            'total_tasks': parse_number(row.get('total_tareas_asignadas')),
            'hours_worked': parse_number(row.get('horas_totales_trabajadas')),
            'avg_hours_per_task': parse_number(row.get('promedio_horas_por_tarea')),
            'tasks_completed': parse_number(row.get('tareas_completadas')),
            'success_rate': parse_number(row.get('porcentaje_exito')),
            'total_cost': parse_number(row.get('costo_total_generado')),
            'labor_cost': parse_number(row.get('costo_mano_obra')),
            'roi_percentage': parse_number(row.get('roi_empleado_porcentaje')),
            'efficiency_rank': parse_number(row.get('ranking_eficiencia'))
        })
    
    return sorted(employees, key=lambda x: x.get('efficiency_rank', 999))


def transform_financial(raw_data):
    """Transform financial data by activity type."""
    print("Transforming financial data...")
    
    financial = []
    for row in raw_data.get('financial', []):
        financial.append({
            'activity_type': translate(row.get('tipo', ''), ACTIVITY_TYPES),
            'total_tasks': parse_number(row.get('total_tareas')),
            'tasks_completed': parse_number(row.get('tareas_completadas')),
            'total_investment': parse_number(row.get('inversion_total')),
            'avg_cost_per_task': parse_number(row.get('costo_promedio_por_tarea')),
            'budget_deviation_pct': parse_number(row.get('desviacion_presupuestaria_pct')),
            'cost_std_dev': parse_number(row.get('desviacion_estandar_costos')),
            'over_budget_pct': parse_number(row.get('pct_tareas_sobre_presupuesto')),
            'avg_hours_per_task': parse_number(row.get('horas_promedio_por_tarea')),
            'cost_per_hour': parse_number(row.get('costo_por_hora')),
            'revenue_generated': parse_number(row.get('ingresos_generados')),
            'roi_percentage': parse_number(row.get('roi_porcentaje'))
        })
    
    return financial


def transform_areas(raw_data):
    """Transform area performance data."""
    print("Transforming area data...")
    
    areas = []
    for row in raw_data.get('areas', []):
        areas.append({
            'area_name': row.get('area_nombre', ''),
            'location_name': row.get('ubicacion_nombre', ''),
            'hectares': parse_number(row.get('hectareas')),
            'soil_type': translate(row.get('tipo_suelo', ''), SOIL_TYPES),
            'total_tasks': parse_number(row.get('total_tareas')),
            'tasks_completed': parse_number(row.get('tareas_completadas')),
            'total_investment': parse_number(row.get('inversion_total')),
            'total_revenue': parse_number(row.get('ingresos_totales')),
            'net_profit': parse_number(row.get('ganancia_neta')),
            'roi_percentage': parse_number(row.get('roi_porcentaje')),
            'total_torvadas': parse_number(row.get('torvadas_totales')),
            'yield_per_hectare': parse_number(row.get('rendimiento_promedio_por_hectarea')),
            'productivity_rank': parse_number(row.get('ranking_productividad')),
            'profitability_rank': parse_number(row.get('ranking_rentabilidad'))
        })
    
    return areas


def transform_kpis(raw_data):
    """Transform and combine KPI data."""
    print("Transforming KPIs...")
    
    kpis = {
        'finance': {},
        'operations': {},
        'productivity': {}
    }
    
    # Finance KPIs
    for row in raw_data.get('kpis_finance', []):
        kpis['finance'] = {
            'total_investment': parse_number(row.get('inversion_total')),
            'avg_task_cost': parse_number(row.get('costo_promedio_tarea')),
            'harvest_revenue': parse_number(row.get('ingresos_cosecha')),
            'net_profit': parse_number(row.get('ganancia_neta')),
            'overall_roi_pct': parse_number(row.get('roi_general_porcentaje')),
            'investment_per_hectare': parse_number(row.get('inversion_por_hectarea'))
        }
        break
    
    # Operations KPIs
    for row in raw_data.get('kpis_operations', []):
        kpis['operations'] = {
            'active_employees': parse_number(row.get('empleados_activos')),
            'specialized_employees': parse_number(row.get('empleados_especializados')),
            'productive_areas': parse_number(row.get('areas_productivas')),
            'active_locations': parse_number(row.get('ubicaciones_activas')),
            'total_tasks': parse_number(row.get('tareas_totales')),
            'tasks_completed': parse_number(row.get('tareas_completadas')),
            'completion_rate_pct': parse_number(row.get('porcentaje_cumplimiento'))
        }
        break
    
    # Productivity KPIs
    for row in raw_data.get('kpis_productivity', []):
        kpis['productivity'] = {
            'total_torvadas': parse_number(row.get('torvadas_totales')),
            'total_kg_produced': parse_number(row.get('kilos_totales_producidos')),
            'avg_yield_per_hectare': parse_number(row.get('rendimiento_promedio_hectarea')),
            'harvests_completed': parse_number(row.get('cosechas_realizadas')),
            'avg_humidity': parse_number(row.get('humedad_promedio')),
            'first_quality_harvests': parse_number(row.get('cosechas_calidad_primera')),
            'first_quality_pct': parse_number(row.get('porcentaje_calidad_primera'))
        }
        break
    
    return kpis


def transform_trends(raw_data):
    """Transform temporal trend data."""
    print("Transforming trends...")
    
    trends = []
    for row in raw_data.get('trends', []):
        trends.append({
            'year': parse_number(row.get('año', row.get('year', 2024))),
            'month': parse_number(row.get('mes', row.get('month'))),
            'month_name': translate(row.get('nombre_mes', row.get('month_name', '')), MONTHS),
            'activity_type': translate(row.get('tipo_actividad', row.get('activity_type', '')), ACTIVITY_TYPES),
            'tasks_started': parse_number(row.get('tareas_iniciadas', row.get('tasks_started'))),
            'tasks_completed': parse_number(row.get('tareas_completadas', row.get('tasks_completed'))),
            'completion_rate': parse_number(row.get('porcentaje_completadas', row.get('completion_rate'))),
            'avg_cost': parse_number(row.get('costo_promedio', row.get('avg_cost'))),
            'avg_duration_hours': parse_number(row.get('duracion_promedio_horas', row.get('avg_duration_hours')))
        })
    
    return trends


def transform_recommendations(raw_data):
    """Transform recommendations data."""
    print("Transforming recommendations...")
    
    recommendations = []
    for row in raw_data.get('recommendations', []):
        recommendations.append({
            'category': row.get('categoria', ''),
            'value': row.get('valor', ''),
            'metric': row.get('metrica', ''),
            'recommendation': row.get('recomendacion', '')
        })
    
    return recommendations


def save_json(data, filename):
    """Save data to JSON file in both processed and web directories."""
    # Save to processed folder
    processed_path = DATA_PROCESSED / filename
    with open(processed_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    # Also save to web/data folder for frontend
    web_path = WEB_DATA / filename
    with open(web_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    
    print(f"  Saved: {filename}")


def load_data():
    """Load all transformed data into JSON files for web consumption."""
    print("\nLoading data to JSON files...")
    
    # Ensure directories exist
    DATA_PROCESSED.mkdir(parents=True, exist_ok=True)
    WEB_DATA.mkdir(parents=True, exist_ok=True)


def run_etl():
    """Main ETL pipeline execution."""
    print("=" * 60)
    print("RICE CROP ANALYTICS - ETL PIPELINE")
    print("=" * 60)
    print(f"Started: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print()
    
    # Extract
    raw_data = extract_data()
    print()
    
    # Transform
    employees = transform_employees(raw_data)
    financial = transform_financial(raw_data)
    areas = transform_areas(raw_data)
    kpis = transform_kpis(raw_data)
    trends = transform_trends(raw_data)
    recommendations = transform_recommendations(raw_data)
    print()
    
    # Load
    load_data()
    save_json(employees, 'employees.json')
    save_json(financial, 'financial.json')
    save_json(areas, 'areas.json')
    save_json(kpis, 'kpis.json')
    save_json(trends, 'trends.json')
    save_json(recommendations, 'recommendations.json')
    
    # Create combined dashboard data
    dashboard_data = {
        'generated_at': datetime.now().isoformat(),
        'summary': {
            'total_employees': len(employees),
            'total_areas': len(set(a['area_name'] for a in areas)),
            'overall_roi': kpis.get('finance', {}).get('overall_roi_pct', 0),
            'completion_rate': kpis.get('operations', {}).get('completion_rate_pct', 0)
        },
        'kpis': kpis,
        'top_employee': employees[0] if employees else None,
        'best_area': max(areas, key=lambda x: x.get('roi_percentage', -999)) if areas else None
    }
    save_json(dashboard_data, 'dashboard.json')
    
    print()
    print("=" * 60)
    print("ETL PIPELINE COMPLETED SUCCESSFULLY")
    print(f"Finished: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)
    
    return True


if __name__ == "__main__":
    run_etl()
