# Rice Crop Analytics Platform

<div align="center">

![Python](https://img.shields.io/badge/Python-ETL-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-Schema-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![ETL](https://img.shields.io/badge/ETL-JSON_Output-success?style=for-the-badge)
![Dashboard](https://img.shields.io/badge/Dashboard-5_Views-0A66C2?style=for-the-badge)
![License](https://img.shields.io/badge/License-MIT-yellow?style=for-the-badge)

<br>

<a href="https://sam-24-dev.github.io/Analisis-Cultivo-Arroz/">
  <img src="https://img.shields.io/badge/Live_Demo-View_Dashboard-0078D4?style=for-the-badge&logo=github&logoColor=white" alt="Live Demo" />
</a>

</div>

---

## Project Overview

This repository contains a portfolio-ready agricultural analytics project that connects database design, Python ETL, and dashboard delivery into one operational workflow. The goal is to move from fragmented field and finance exports to a clearer view of ROI recovery, productivity, efficiency, and area-level performance.

The project combines:
- MySQL schema and analytical query design
- Python ETL that converts raw exports into dashboard-ready JSON
- a browser-based dashboard with five views for operational review
- KPI storytelling focused on profitability recovery and planning

---

## Challenge / Solution / Impact

| Challenge | Solution | Impact |
|---|---|---|
| Negative ROI and limited operational visibility made profitability hard to diagnose | Built a MySQL -> Python ETL -> JSON -> web dashboard workflow | Clear recovery path from `-5.58%` ROI to a `+15%` target |
| KPI signals were spread across multiple raw exports | Consolidated source files into reusable JSON outputs for dashboard consumption | Faster monitoring of finance, productivity, and area performance |
| Manual reporting slowed decision-making for the agricultural operation | Delivered a five-view web dashboard for executive and operational review | More consistent analysis across employees, finance, areas, and strategic insights |

---

## Key Metrics

| Metric | Current | Target | Improvement |
|---|---:|---:|---:|
| ROI | -5.58% | +15.00% | +20.6 pts |
| Efficiency | 72.7% | 90.0% | +17.3 pts |
| Productivity | 28.5 units | 50.0 units | +75% |
| Quality | 100% first class | 100% | Maintained |

---

## Pipeline Architecture

```text
MySQL schema + analytical exports
        ->
Python ETL (etl/extract_transform.py)
        ->
JSON outputs in data/processed and web/data
        ->
Web dashboard with 5 analytical views
```

| Layer | Technologies | Output |
|---|---|---|
| Data source | MySQL schema, SQL queries, CSV exports | Raw operational and financial inputs |
| Transformation | Python ETL | Cleaned, aggregated, and dashboard-ready JSON |
| Delivery | HTML, CSS, JavaScript, Bootstrap, Chart.js | Five dashboard pages for browser review |

---

## Dashboard Scope

| Page | Purpose |
|---|---|
| Dashboard | Executive KPIs, investment view, and task-level status |
| Employees | Productivity rankings, worker efficiency, and ROI by employee |
| Financial | Cost structure, ROI by activity, and budget tracking |
| Areas | Geographic performance and soil-type context |
| Insights | Trends, recommendations, and action-oriented summary |

---

## Tech Stack

| Layer | Technologies |
|---|---|
| Database | MySQL 8.0, stored procedures, triggers, views |
| ETL | Python 3, JSON, standard libraries |
| Testing | pytest |
| Frontend | HTML5, CSS3, JavaScript, Bootstrap 5 |
| Visualization | Chart.js |
| Hosting | GitHub Pages |

---

## Quick Start

```bash
# clone repository
git clone https://github.com/Sam-24-dev/Analisis-Cultivo-Arroz.git
cd Analisis-Cultivo-Arroz

# install dependencies
pip install -r requirements.txt

# run ETL pipeline
python etl/extract_transform.py

# run tests
python -m pytest tests/ -v

# serve dashboard locally
cd web
python -m http.server 8000
```

Optional MySQL setup:

```sql
SOURCE database/schema.sql;
SOURCE database/queries.sql;
```

---

## Project Structure

```text
Analisis-Cultivo-Arroz/
|- config/                 # ETL settings and shared constants
|- data/
|  |- raw/                 # Source exports used by the pipeline
|  `- processed/           # ETL outputs and dashboard-ready JSON backups
|- database/               # Schema and analytical SQL
|- docs/                   # Technical documentation
|- etl/                    # Main ETL script
|- tests/                  # Automated ETL validation
|- web/                    # Dashboard pages, JS modules, and production JSON
|- .env.example
|- Makefile
|- requirements.txt
`- README.md
```

---

## Documentation

- Technical architecture: [docs/architecture.md](./docs/architecture.md)
- Main ETL entrypoint: [etl/extract_transform.py](./etl/extract_transform.py)
- Dashboard entrypoint: [web/index.html](./web/index.html)

---

<div align="center">

### Author

**Samir Caizapasto**  
*Junior Data Engineer & Analyst*

[![Visit portfolio website](https://img.shields.io/badge/Portfolio-Visit_Website-success?style=for-the-badge&logo=vercel&logoColor=white)](https://portafolio-samir-tau.vercel.app/)
[![Connect on LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0A66C2?style=for-the-badge&logo=linkedin&logoColor=white)](https://www.linkedin.com/in/samir-caizapasto/)
[![Contact by email](https://img.shields.io/badge/Email-Contact-EA4335?style=for-the-badge&logo=gmail&logoColor=white)](mailto:samir.leonardo.caizapasto04@gmail.com)

</div>

---

If this project was useful or interesting, consider starring the repository.
