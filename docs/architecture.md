# Rice Crop Analytics Platform - Architecture Documentation

## System Overview

This platform implements a three-layer data architecture for agricultural analytics:

```
[Data Sources] → [ETL Pipeline] → [Web Dashboard]
     CSV            Python           Chart.js
```

## Data Flow

### 1. Data Ingestion (Extract)
- Source: MySQL database exports as CSV files
- Location: `data/raw/`
- Files: 10 CSV files covering employees, areas, finances, KPIs, trends

### 2. Data Transformation (Transform)
- Script: `etl/extract_transform.py`
- Functions:
  - `extract_data()`: Loads CSV files into memory
  - `transform_employees()`: Calculates productivity metrics
  - `transform_financial()`: Aggregates costs by activity
  - `transform_areas()`: Computes area performance and ROI
  - `transform_kpis()`: Combines KPI data from multiple sources
  - `transform_trends()`: Processes temporal data
  - `transform_recommendations()`: Generates actionable insights

### 3. Data Loading (Load)
- Output: JSON files for web consumption
- Locations:
  - `data/processed/` (backup)
  - `web/data/` (production)

## Database Schema

### Core Tables
- `employees`: Worker information and roles
- `areas`: Geographic zones and soil types
- `activities`: Agricultural tasks and costs
- `production`: Harvest results and quality

### Analytical Views
- `employee_productivity`: Performance metrics by worker
- `area_performance`: ROI and efficiency by zone
- `financial_analysis`: Cost breakdown by activity type

## Frontend Architecture

### Pages
| Page | Data Source | Purpose |
|------|-------------|---------|
| index.html | dashboard.json | Executive overview |
| employees.html | employees.json | Productivity analysis |
| financial.html | financial.json | Cost management |
| areas.html | areas.json | Geographic insights |
| insights.html | recommendations.json | Strategic planning |

### JavaScript Modules
- `main.js`: Shared utilities and data loading
- `dashboard.js`: KPI cards and summary charts
- `employees.js`: Productivity tables and rankings
- `financial.js`: Cost analysis and ROI charts
- `areas.js`: Geographic performance visualization
- `insights.js`: Recommendations and trends

## Deployment

### Local Development
```bash
cd web
python -m http.server 8000
```

### Production
Deployed via GitHub Pages from the `Gh-Pages` branch.

## Future Improvements

1. **Database Migration**: PostgreSQL for production workloads
2. **Orchestration**: Apache Airflow for scheduled ETL runs
3. **Containerization**: Docker for environment consistency
4. **API Layer**: FastAPI for programmatic data access
