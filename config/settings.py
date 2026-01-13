"""
ETL Pipeline Configuration
"""

from pathlib import Path

# Base paths
BASE_DIR = Path(__file__).parent.parent
DATA_DIR = BASE_DIR / "data"
RAW_DIR = DATA_DIR / "raw"
PROCESSED_DIR = DATA_DIR / "processed"
WEB_DATA_DIR = BASE_DIR / "web" / "data"

# Output files
OUTPUT_FILES = [
    "employees.json",
    "financial.json",
    "areas.json",
    "kpis.json",
    "trends.json",
    "recommendations.json",
    "dashboard.json"
]

# Translation mappings
MONTH_TRANSLATION = {
    'Enero': 'January', 'Febrero': 'February', 'Marzo': 'March',
    'Abril': 'April', 'Mayo': 'May', 'Junio': 'June',
    'Julio': 'July', 'Agosto': 'August', 'Septiembre': 'September',
    'Octubre': 'October', 'Noviembre': 'November', 'Diciembre': 'December'
}

ACTIVITY_TRANSLATION = {
    'Siembra': 'Planting', 'Cosecha': 'Harvest',
    'Aplicacion': 'Application', 'Riego': 'Irrigation'
}

STATUS_TRANSLATION = {
    'Completada': 'Completed', 'Pendiente': 'Pending', 'En Progreso': 'In Progress'
}
