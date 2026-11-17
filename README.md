
# Job Market Intelligence — SQL & Power BI

## Project Overview

An end-to-end job market analytics project using Python, PostgreSQL, SQL, DAX, and Power BI to collect, clean, validate, and analyze job listings.

The project analyzes 300 job listings collected from the Arbeitnow API, primarily representing European job opportunities.

## Tools & Technologies

- **Python:** API data collection and JSON processing
- **PostgreSQL:** Data storage, cleaning, and validation
- **SQL:** Data quality checks and analytical queries
- **Power BI:** Interactive dashboards and reporting
- **DAX:** KPI calculations and job market metrics

## Key Findings

- Total Job Listings: **300**
- Remote Jobs: **33 (11%)**
- Non-Remote Jobs: **267 (89%)**
- Hiring Companies: **169**
- Distinct Location Values: **131**
- Employment Type Not Specified: **36 (12%)**
- Job Categories: **8**
- Other / Unclassified Jobs: **183 (61%)**

## Dashboard Pages

1. **Overview:** Job market KPIs, employment types, and top locations.
2. **Employment Analysis:** Hiring companies, employment-type distribution, and job categories.
3. **Location Intelligence:** Location rankings and remote-work comparisons.
4. **Remote Work Analysis:** Remote versus non-remote opportunities.
5. **Data Quality & Insights:** Missing employment types and classification coverage.

## Data Processing Workflow

1. Collect job listings from the Arbeitnow API using Python.
2. Store raw records in PostgreSQL.
3. Clean and standardize job data using SQL.
4. Validate missing values and duplicate identifiers.
5. Connect PostgreSQL to Power BI.
6. Build DAX measures and interactive dashboard pages.

## Data Limitations

The dataset is a sample of 300 listings, not a representative survey of the global job market. Locations are source-provided text values and may include remote-work labels or missing values.

Job categories are assigned using keyword-based rules and should be treated as approximate classifications. The remote-work figures reflect the API's remote flag.

## Dashboard Screenshots

### Overview
![Overview](screenshots/01-overview.png)

### Employment Analysis
![Employment](screenshots/02-employment.png)

### Location Intelligence
![Locations](screenshots/03-locations.png)

### Remote Work Analysis
![Remote Work](screenshots/04-remote-work.png)

### Data Quality
![Data Quality](screenshots/05-data-quality.png)

## Project Status

Five-page interactive Power BI dashboard completed. The report can be opened locally using Power BI Desktop.