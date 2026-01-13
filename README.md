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

End-to-end data engineering solution for agricultural operations that transforms raw field data into actionable business intelligence.

| Challenge | Solution | Impact |
|-----------|----------|--------|
| Negative ROI (-5.58%) | Automated ETL pipeline | Strategic plan to reach +15% ROI |
| Lack of data visibility | Interactive dashboard | Real-time KPI monitoring |
| Manual reporting | Python data processing | Time savings & accuracy |

> **Core Value:** This platform bridges the gap between agricultural operations and business intelligence, providing a production-ready architecture to digitize field data and optimize financial decision-making.

---

## Pipeline Architecture

This project implements an **automated ETL pipeline** that processes source data and generates JSON outputs for web consumption:

```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   MySQL     │────▶│   Python    │────▶│    JSON     │────▶│    Web      │
│  Database   │     │    ETL      │     │   Output    │     │  Dashboard  │
└─────────────┘     └─────────────┘     └─────────────┘     └─────────────┘
     Schema         extract_transform.py    7 files         5 pages
```

| Layer | Component | Output |
|-------|-----------|--------|
| **Source** | MySQL Schema | Tables, triggers, stored procedures |
| **Processing** | Python ETL | Extracts CSVs, calculates KPIs |
| **Storage** | JSON Export | 7 data files in `web/data/` |
| **Presentation** | Web Dashboard | 5 interactive pages with Chart.js |

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
| **Testing** | pytest |
| **Frontend** | HTML5, CSS3, JavaScript (ES6+), Bootstrap 5 |
| **Visualization** | Chart.js |
| **Deployment** | GitHub Pages |

---

## Quick Start

```bash
# Clone repository
git clone https://github.com/Sam-24-dev/Analisis-Cultivo-Arroz.git
cd Analisis-Cultivo-Arroz

# Install dependencies
pip install -r requirements.txt

# Run ETL pipeline
python etl/extract_transform.py

# Run tests
python -m pytest tests/ -v

# Start local server
cd web && python -m http.server 8000
```

For MySQL setup (optional):
```sql
SOURCE database/schema.sql;
SOURCE database/queries.sql;
```

---

## Project Structure

```
Analisis-Cultivo-Arroz/
├── config/                   # Configuration
│   └── settings.py           # ETL settings and constants
├── data/
│   ├── raw/                  # Source CSV files (10 files)
│   └── processed/            # Cleaned JSON data (7 files)
├── database/
│   ├── schema.sql            # Database schema
│   └── queries.sql           # Analytical queries
├── docs/
│   └── architecture.md       # Technical documentation
├── etl/
│   └── extract_transform.py  # Main ETL script (15 functions)
├── tests/
│   └── test_etl.py           # Unit tests (14 tests)
├── web/
│   ├── css/                  # Styles
│   ├── js/                   # Application logic (6 modules)
│   ├── data/                 # JSON files (ETL output)
│   ├── index.html            # Main Dashboard
│   ├── employees.html        # Productivity Analysis
│   ├── financial.html        # Financial Analysis
│   ├── areas.html            # Area Performance
│   └── insights.html         # Strategic Insights
├── .env.example              # Environment template
├── .gitignore
├── LICENSE
├── Makefile                  # Automation commands
├── README.md
└── requirements.txt
```

---

## Scalability & Roadmap

The architecture is designed to scale for production workloads:

- **Database:** Migration path to PostgreSQL/Snowflake for high-volume warehousing
- **Orchestration:** ETL structure is compatible with Apache Airflow for scheduled runs
- **Containerization:** Ready for Docker deployment to standardize environment
- **API Layer:** FastAPI integration for programmatic data access

---

<div align="center">

### Author

**Samir Caizapasto**  
*Junior Data Engineer & Analyst*

[![](https://img.shields.io/badge/LinkedIn-Connect-0077B5?style=for-the-badge&logo=linkedin)](https://www.linkedin.com/in/samir-caizapasto/)
[![](https://img.shields.io/badge/Portfolio-Visit-00d4ff?style=for-the-badge&logo=vercel)](https://portafolio-samir-tau.vercel.app/)
[![](https://img.shields.io/badge/GitHub-Follow-181717?style=for-the-badge&logo=github)](https://github.com/Sam-24-dev)

</div>

---

<div align="center">

⭐ If this project demonstrates useful data engineering practices, please give it a star.

</div>
