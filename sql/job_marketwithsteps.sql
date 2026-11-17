-- 1. Total job listings
SELECT COUNT(*) AS total_jobs
FROM clean_jobs;

-- 2. Jobs by remote status
SELECT remote, COUNT(*) AS total_jobs
FROM clean_jobs
GROUP BY remote
ORDER BY total_jobs DESC;

-- 3. Top 10 hiring companies
SELECT company_name, COUNT(*) AS total_jobs
FROM clean_jobs
GROUP BY company_name
ORDER BY total_jobs DESC, company_name ASC
LIMIT 10;

-- 4. Top 15 nonblank locations
SELECT location, COUNT(*) AS total_jobs
FROM clean_jobs
WHERE NULLIF(TRIM(location), '') IS NOT NULL
GROUP BY location
ORDER BY total_jobs DESC, location ASC
LIMIT 15;

-- 5. Missing employment types
SELECT COUNT(*) AS missing_employment_types
FROM clean_jobs
WHERE NULLIF(TRIM(employment_type), '') IS NULL;

-- 6. Duplicate source identifiers
SELECT source_slug, COUNT(*) AS occurrences
FROM clean_jobs
GROUP BY source_slug
HAVING COUNT(*) > 1;