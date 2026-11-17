
import json
from datetime import datetime, timezone
from pathlib import Path
from getpass import getpass

import psycopg2
from psycopg2.extras import Json, execute_values

BASE_DIR = Path(__file__).resolve().parent
RAW_FILE = BASE_DIR / "data" / "raw_jobs.json"


def parse_created_at(value):
    if not value:
        return None

    if isinstance(value, (int, float)):
        return datetime.fromtimestamp(value, tz=timezone.utc)

    if isinstance(value, str):
        try:
            return datetime.fromisoformat(value.replace("Z", "+00:00"))
        except ValueError:
            return None

    return None


def main():
    with RAW_FILE.open("r", encoding="utf-8") as file:
        payload = json.load(file)

    jobs = payload.get("jobs", [])
    if not jobs:
        print("No jobs found in the JSON file.")
        return

    password = getpass("Enter your PostgreSQL password: ")

    connection = psycopg2.connect(
        host="localhost",
        port=5432,
        dbname="job_market_intelligence",
        user="postgres",
        password=password,
    )

    rows = []
    for job in jobs:
        job_types = job.get("job_types") or job.get("job_type") or []
        if isinstance(job_types, list):
            employment_type = ", ".join(str(x) for x in job_types)
        else:
            employment_type = str(job_types) if job_types else None

        rows.append((
            job.get("slug"),
            job.get("title"),
            job.get("company_name"),
            job.get("location"),
            job.get("remote"),
            employment_type,
            job.get("url"),
            job.get("description"),
            Json(job.get("tags") or []),
            parse_created_at(job.get("created_at")),
        ))

    sql = """
        INSERT INTO raw_jobs (
            source_slug, title, company_name, location, remote,
            employment_type, job_url, description, tags, created_at
        )
        VALUES %s
        ON CONFLICT (source_slug) DO NOTHING
    """

    try:
        with connection:
            with connection.cursor() as cursor:
                execute_values(cursor, sql, rows)
                inserted = cursor.rowcount

        print(f"Jobs in JSON file: {len(jobs)}")
        print(f"Rows inserted: {inserted}")
        print("Import completed successfully.")
    finally:
        connection.close()


if __name__ == "__main__":
    main()
