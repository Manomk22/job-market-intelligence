CREATE TABLE raw_jobs (
    job_id BIGSERIAL PRIMARY KEY,
    source_slug TEXT UNIQUE,
    title TEXT,
    company_name TEXT,
    location TEXT,
    remote BOOLEAN,
    employment_type TEXT,
    job_url TEXT,
    description TEXT,
    tags JSONB,
    created_at TIMESTAMPTZ,
    collected_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);
SELECT table_name
FROM information_schema.tables
WHERE table_schema = 'public'
  AND table_name = 'raw_jobs';

  SELECT * 
FROM raw_jobs;

SELECT COUNT(*) AS total_jobs
FROM raw_jobs;

SELECT
    COUNT(*) AS total_jobs,
    COUNT(*) FILTER (WHERE title IS NULL OR TRIM(title) = '') AS missing_titles,
    COUNT(*) FILTER (WHERE company_name IS NULL OR TRIM(company_name) = '') AS missing_companies,
    COUNT(*) FILTER (WHERE location IS NULL OR TRIM(location) = '') AS missing_locations,
    COUNT(*) FILTER (WHERE job_url IS NULL OR TRIM(job_url) = '') AS missing_urls,
    COUNT(*) FILTER (WHERE description IS NULL OR TRIM(description) = '') AS missing_descriptions
FROM raw_jobs;

SELECT
    source_slug,
    COUNT(*) AS duplicate_count
FROM raw_jobs
WHERE source_slug IS NOT NULL
GROUP BY source_slug
HAVING COUNT(*) > 1;

SELECT
    employment_type,
    COUNT(*) AS job_count
FROM raw_jobs
GROUP BY employment_type
ORDER BY job_count DESC
LIMIT 20;

SELECT
 location,
 count (*) as job_count
 from raw_jobs
 group by location
 order by job_count DESC
 limit 20;
 
CREATE TABLE clean_jobs AS
SELECT
    job_id,
    NULLIF(TRIM(source_slug), '') AS source_slug,
    NULLIF(TRIM(title), '') AS title,
    NULLIF(TRIM(company_name), '') AS company_name,
    NULLIF(TRIM(location), '') AS location,
    remote,
    NULLIF(TRIM(employment_type), '') AS employment_type,
    NULLIF(TRIM(job_url), '') AS job_url,
    NULLIF(
        REGEXP_REPLACE(
            REGEXP_REPLACE(
                COALESCE(description, ''),
                '<[^>]*>', ' ', 'g'
            ),
            '\s+', ' ', 'g'
        ),
        ''
    ) AS description,
    tags,
    created_at,
    collected_at
FROM raw_jobs;


SELECT
    (SELECT COUNT(*) FROM raw_jobs) AS raw_count,
    (SELECT COUNT(*) FROM clean_jobs) AS clean_count;

	SELECT title, company_name, description
FROM clean_jobs
LIMIT 5;

SELECT COUNT(*) AS incomplete_records
FROM clean_jobs
WHERE title IS NULL
   OR company_name IS NULL;

   SELECT
    CASE
        WHEN remote = TRUE THEN 'Remote'
        WHEN remote = FALSE THEN 'Non-Remote'
        ELSE 'Not Specified'
    END AS work_type,
    COUNT(*) AS total_jobs,
    ROUND(
        COUNT(*) * 100.0 / SUM(COUNT(*)) OVER (),
        2
    ) AS percentage
FROM clean_jobs
GROUP BY work_type
ORDER BY total_jobs DESC;


SELECT
    COALESCE(employment_type, 'Not Specified') AS employment_type,
    COUNT(*) AS total_jobs
FROM clean_jobs
GROUP BY employment_type
ORDER BY total_jobs DESC
LIMIT 10;


SELECT
    location,
    COUNT(*) AS total_jobs
FROM clean_jobs
WHERE location IS NOT NULL
GROUP BY location
ORDER BY total_jobs DESC, location
LIMIT 10;

SELECT * from clean_jobs;

SELECT
    company_name,
    COUNT(*) AS total_jobs
FROM clean_jobs
WHERE company_name IS NOT NULL
GROUP BY company_name
ORDER BY total_jobs DESC, company_name
LIMIT 10;

SELECT
    CASE
        WHEN title ILIKE '%data analyst%' THEN 'Data Analyst'
        WHEN title ILIKE '%business analyst%' THEN 'Business Analyst'
        WHEN title ILIKE '%sql%' THEN 'SQL-related'
        WHEN title ILIKE '%developer%' THEN 'Developer'
        WHEN title ILIKE '%engineer%' THEN 'Engineer'
        ELSE 'Other'
    END AS job_category,
    COUNT(*) AS total_jobs
FROM clean_jobs
GROUP BY job_category
ORDER BY total_jobs DESC;

SELECT
    location,
    COUNT(*) AS total_jobs,
    RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS location_rank,
    DENSE_RANK() OVER (
        ORDER BY COUNT(*) DESC
    ) AS dense_location_rank
FROM clean_jobs
WHERE location IS NOT NULL
GROUP BY location
ORDER BY total_jobs DESC;


SELECT
    COALESCE(employment_type, 'Not Specified') AS employment_type,
    COUNT(*) AS total_jobs,
    ROUND(
        COUNT(*) * 100.0 /
        SUM(COUNT(*)) OVER (),
        2
    ) AS percentage_of_total
FROM clean_jobs
GROUP BY employment_type
ORDER BY total_jobs DESC;

WITH company_counts AS (
    SELECT
        company_name,
        COUNT(*) AS total_jobs
    FROM clean_jobs
    WHERE company_name IS NOT NULL
    GROUP BY company_name
)
SELECT
    company_name,
    total_jobs,
    LAG(total_jobs) OVER (
        ORDER BY total_jobs DESC, company_name
    ) AS previous_company_jobs,
    total_jobs -
        LAG(total_jobs) OVER (
            ORDER BY total_jobs DESC, company_name
        ) AS difference_from_previous
FROM company_counts
ORDER BY total_jobs DESC, company_name
LIMIT 15;


SELECT
    location,
    COUNT(*) AS total_jobs
FROM clean_jobs
WHERE location IS NOT NULL
GROUP BY location
HAVING COUNT(*) > (
    SELECT AVG(location_job_count)
    FROM (
        SELECT
            COUNT(*) AS location_job_count
        FROM clean_jobs
        WHERE location IS NOT NULL
        GROUP BY location
    ) AS location_counts
)
ORDER BY total_jobs DESC;


SELECT
    company_name,
    COUNT(*) AS total_jobs
FROM clean_jobs
WHERE company_name IS NOT NULL
GROUP BY company_name
HAVING COUNT(*) > (
    SELECT AVG(company_job_count)
    FROM (
        SELECT COUNT(*) AS company_job_count
        FROM clean_jobs
        WHERE company_name IS NOT NULL
        GROUP BY company_name
    ) AS company_counts
)
ORDER BY total_jobs DESC;


SELECT
    j.title,
    j.company_name,
    j.location,
    (
        SELECT COUNT(*)
        FROM clean_jobs AS j2
        WHERE j2.company_name = j.company_name
    ) AS company_total_jobs
FROM clean_jobs AS j
WHERE j.company_name IS NOT NULL
ORDER BY company_total_jobs DESC, j.company_name
LIMIT 20;