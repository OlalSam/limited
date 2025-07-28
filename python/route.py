import requests
import json
import time
from datetime import datetime

# Replace with your actual API key and endpoint details
API_KEY = "ywGBdATh8DKWpJvmaKhZuBTdPJDCIPpT"
BASE_URL = "https://api.tomtom.com/traffic/trafficstats"
VERSION = "1"

def submit_route_analysis_job(payload):
    """Submit a route analysis job to TomTom Traffic Stats API."""
    url = f"{BASE_URL}/routeanalysis/{VERSION}?key={API_KEY}"
    headers = {"Content-Type": "application/json"}
    response = requests.post(url, headers=headers, json=payload, timeout=10)
    response.raise_for_status()
    return response.json()

def check_job_status(job_id):
    """Poll the job status using the job_id."""
    url = f"{BASE_URL}/status/{VERSION}/{job_id}?key={API_KEY}"
    response = requests.get(url, timeout=10)
    response.raise_for_status()
    return response.json()

def download_results(result_url, output_filename):
    """Download the results from the provided URL and save them as JSON."""
    response = requests.get(result_url, timeout=10)
    response.raise_for_status()
    with open(output_filename, "w") as f:
        f.write(response.text)
    print(f"Results saved to {output_filename}")

def main():
    # Sample payload for route analysis
    payload = {
        "jobName": "Test Route Analysis Job",
        "distanceUnit": "KILOMETERS",
        "mapVersion": "2022.12",
        "acceptMode": "AUTO",
        "routes": [
            {
                "name": "Outering Road Route",
                "start": {
                    "latitude": -1.246004,
                    "longitude": 36.866922
                },
                "via": [
                    {
                        "latitude": -1.300000,
                        "longitude": 36.870000
                    }
                ],
                "end": {
                    "latitude": -1.322967,
                    "longitude": 36.898350
                },
                "fullTraversal": False,
                "zoneId": "Africa/Nairobi",
                "probeSource": "ALL"
            }
        ],
        "dateRanges": [
            {
                "name": "Recent Week",
                "from": "2023-09-01",
                "to": "2023-09-07",
                "exclusions": []
            }
        ],
        "timeSets": [
            {
                "name": "Weekday Morning",
                "timeGroups": [
                    {
                        "days": ["MON", "TUE", "WED", "THU", "FRI"],
                        "times": ["07:00-09:00"]
                    }
                ]
            }
        ]
    }
    
    try:
        print("Submitting route analysis job...")
        job_response = submit_route_analysis_job(payload)
        print("Job submitted:", job_response)
        
        job_id = job_response.get("jobId")
        if not job_id:
            print("No jobId returned. Exiting.")
            return
        
        # Poll for job status until DONE (or an error state)
        status = ""
        while status not in ("DONE", "ERROR", "REJECTED"):
            print("Waiting for job to complete...")
            time.sleep(5)
            status_response = check_job_status(job_id)
            status = status_response.get("jobState")
            print(f"Current job state: {status}")
        
        if status != "DONE":
            print("Job did not complete successfully. Final status:", status)
            return
        
        # Once job is DONE, look for the JSON result URL in the response
        result_urls = status_response.get("urls", [])
        json_url = next((url for url in result_urls if "json" in url.lower()), None)
        
        if json_url:
            timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
            output_filename = f"route_analysis_{job_id}_{timestamp}.json"
            download_results(json_url, output_filename)
        else:
            print("No JSON result URL found in the response.")
            
    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()

