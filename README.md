# Rice Crop Analytics Platform

<div align="center">

![Data Engineer](https://img.shields.io/badge/Role-Data_Engineer-orange?style=for-the-badge&logo=apache-spark&logoColor=white)
![Data Analyst](https://img.shields.io/badge/Role-Data_Analyst-blue?style=for-the-badge&logo=google-analytics&logoColor=white)
![Status](https://img.shields.io/badge/Status-Completed-success?style=for-the-badge)
![Pipeline](https://img.shields.io/badge/Pipeline-ETL_Automated-blueviolet?style=for-the-badge)

<br>

<a href="https://sam-24-dev.github.io/Analisis-Cultivo-Arroz/">
  <img src="https://img.shields.io/badge/View_Live_Demo-Dashboard-2EA44F?style=for-the-badge&logo=google-chrome&logoColor=white" />
</a>

</div>

---

## Project Overview

A data-driven solution for rice crop management that transforms agricultural data into actionable business insights.

| Challenge | Solution | Impact |
|-----------|----------|--------|
| Negative ROI (-5.58%) | End-to-end data pipeline | Strategic plan to reach +15% ROI |
| Lack of data visibility | Interactive dashboard | Real-time KPI monitoring |
| Manual reporting | Automated ETL process | Time savings & accuracy |

> **Core Value:** This project demonstrates a complete **Data Engineering workflow** — from database design to ETL automation to frontend visualization — solving a real agricultural business problem.

---

## Pipeline Architecture

This project implements an **automated data pipeline** where Python processes source data and generates JSON outputs for the web dashboard:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   MySQL     │────▶│   Python    │────▶│    JSON     │────▶│    Web      │
│  Database   │     │    ETL      │     │   Files     │     │  Dashboard  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
     Schema          extract_transform.py     data/          Chart.js
     Queries                                 7 files         5 pages
```

| Component | Output |
|-----------|--------|
| MySQL Schema | Tables, triggers, stored procedures |
| Python ETL | Processes CSVs, calculates KPIs |
| JSON Export | 7 data files in `web/data/` |
| Web Dashboard | 5 interactive pages with Chart.js |

---

## Key Metrics & Results

| Metric | Current | Target | Improvement |
|--------|---------|--------|-------------|
| **ROI** | -5.58% | +15% | +20.6 pts |
| **Efficiency** | 72.7% | 90% | +17.3 pts |
| **Productivity** | 28.5 units | 50 units | +75% |
| **Quality** | 100% First Class | 100% | Maintained |

---

## Dashboard Features

The web dashboard provides comprehensive analytics across 5 specialized views:

| Page | Purpose |
|------|---------|
| **Dashboard** | Executive KPIs, investment charts, task status |
| **Employees** | Productivity rankings, efficiency metrics, ROI by worker |
| **Financial** | Cost breakdown, ROI by activity, budget variance |
| **Areas** | Geographic performance, soil type analysis |
| **Insights** | AI recommendations, trend analysis, action plans |

---

## Tech Stack

| Layer | Technologies |
|-------|--------------|
| **Database** | MySQL 8.0, Stored Procedures, Triggers, Views |
| **ETL Pipeline** | Python 3, JSON, Standard Libraries |
| **Analysis** | Pandas, Plotly, Jupyter Notebook |
| **Frontend** | HTML5, CSS3, JavaScript (ES6+), Bootstrap 5 |
| **Visualization** | Chart.js |
| **Deployment** | GitHub Pages |

---

## How to Run

### 1. Run ETL Pipeline
```bash
cd Analisis-Cultivo-Arroz
python etl/extract_transform.py
```

### 2. Launch Dashboard
```bash
cd web
python -m http.server 8000
# Open http://localhost:8000
```

### 3. Database Setup (Optional)
```sql
-- MySQL
SOURCE database/schema.sql;
SOURCE database/queries.sql;
```

---

## Project Structure

```
Analisis-Cultivo-Arroz/
├── database/                 # Data Engineering Core
│   ├── schema.sql            # Database schema
│   └── queries.sql           # Analytical queries
├── etl/                      # ETL Pipeline
│   └── extract_transform.py  # Python ETL script
├── data/                     # Data Storage
│   ├── raw/                  # Source CSV files
│   └── processed/            # Cleaned data
├── web/                      # Frontend Dashboard
│   ├── index.html            # Main Dashboard
│   ├── employees.html        # Productivity Analysis
│   ├── financial.html        # Financial Analysis
│   ├── areas.html            # Area Performance
│   ├── insights.html         # Strategic Insights
│   ├── css/                  # Styles
│   ├── js/                   # Application Logic
│   └── data/                 # JSON files (ETL output)
├── README.md
└── LICENSE
```

---

<div align="center">

### Author

**Samir Caizapasto**  
*Junior Data Engineer & Analyst*

[![](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/samircaizapasto/)
[![](https://img.shields.io/badge/Portfolio-Visit-00d4ff?style=for-the-badge&logo=vercel)](https://portafolio-samir-tau.vercel.app/)
[![](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github)](https://github.com/Sam-24-dev)

</div>

---

<div align="center">

⭐ If this project demonstrates useful data engineering practices, please give it a star.

</div>
