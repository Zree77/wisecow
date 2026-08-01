#!/usr/bin/env python3
"""
Application Health Checker
Checks whether a target application is 'up' or 'down' based on HTTP status codes.
"""

import sys
import time
import urllib.request
import urllib.error
from datetime import datetime

# Default target: local Wisecow service (adjust as needed)
TARGET_URL = "http://localhost:4499"
TIMEOUT_SECONDS = 5
CHECK_INTERVAL_SECONDS = 10
LOGFILE = "app_health_checker.log"


def timestamp():
    return datetime.now().strftime("%Y-%m-%d %H:%M:%S")


def log(message):
    line = f"[{timestamp()}] {message}"
    print(line)
    with open(LOGFILE, "a") as f:
        f.write(line + "\n")


def check_health(url):
    try:
        req = urllib.request.Request(url, method="GET")
        with urllib.request.urlopen(req, timeout=TIMEOUT_SECONDS) as response:
            status_code = response.getcode()
            if 200 <= status_code < 400:
                log(f"UP - {url} responded with status {status_code}")
                return True
            else:
                log(f"DOWN - {url} responded with unexpected status {status_code}")
                return False
    except urllib.error.HTTPError as e:
        log(f"DOWN - {url} returned HTTP error {e.code}")
        return False
    except urllib.error.URLError as e:
        log(f"DOWN - {url} unreachable: {e.reason}")
        return False
    except Exception as e:
        log(f"DOWN - {url} check failed: {str(e)}")
        return False


def main():
    url = sys.argv[1] if len(sys.argv) > 1 else TARGET_URL
    log(f"Starting health check for {url}")
    check_health(url)
    log("Health check completed.")


if __name__ == "__main__":
    main()
