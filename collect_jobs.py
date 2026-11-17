import json
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

API_URL = "https://www.arbeitnow.com/api/job-board-api"

BASE_DIR = Path(__file__).resolve().parent
DATA_DIR = BASE_DIR / "data"
RAW_FILE = DATA_DIR / "raw_jobs.json"

def collect_jobs():
    DATA_DIR.mkdir(parents=True, exist_ok=True)

    request = urllib.request.Request(
        API_URL,
        headers={"User-Agent": "JobMarketIntelligence/1.0"}
    )

    print("Connecting to the job listings API...")

    with urllib.request.urlopen(request, timeout=30) as response:
        payload = json.loads(response.read().decode("utf-8"))

    jobs = payload.get("data", [])

    if not isinstance(jobs, list):
        raise ValueError("Unexpected API response: 'data' is not a list.")

    collected_at = datetime.now(timezone.utc).isoformat()

    output = {
        "source": API_URL,
        "collected_at_utc": collected_at,
        "record_count": len(jobs),
        "jobs": jobs
    }

    with RAW_FILE.open("w", encoding="utf-8") as file:
        json.dump(output, file, ensure_ascii=False, indent=2)

    print(f"Collection completed: {len(jobs)} job listings")
    print(f"Saved to: {RAW_FILE}")

    if jobs:
        first_job = jobs[0]
        print("\nSample record:")
        print("Title:", first_job.get("title"))
        print("Company:", first_job.get("company_name"))
        print("Location:", first_job.get("location"))
        print("Remote:", first_job.get("remote"))

if __name__ == "__main__":
    collect_jobs()
