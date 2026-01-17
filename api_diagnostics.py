#!/usr/bin/env python3
import json
import sys

import requests

API_BASE = "http://api.acmanager.usermd.net"


def test_connectivity():
    print("=== 1. BASIC CONNECTIVITY TEST ===")
    try:
        # Test basic connectivity
        response = requests.get(f"{API_BASE}/", timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")
        print(f"Content: {response.text[:500]}...")
        return response.status_code == 200
    except Exception as e:
        print(f"ERROR: {e}")
        return False


def test_api_root():
    print("\n=== 2. API ROOT TEST ===")
    try:
        response = requests.get(f"{API_BASE}/api/", timeout=30)
        print(f"Status: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")
        print(f"Content: {response.text[:500]}...")
        # Any of these is better than 500
        return response.status_code in [200, 403, 404]
    except Exception as e:
        print(f"ERROR: {e}")
        return False


def test_login_endpoint():
    print("\n=== 3. LOGIN ENDPOINT TEST ===")
    try:
        login_data = {
            "username": "test",
            "password": "test"
        }

        response = requests.post(
            f"{API_BASE}/api/login/",
            json=login_data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )

        print(f"Status: {response.status_code}")
        print(f"Headers: {dict(response.headers)}")

        # Try to parse as JSON
        try:
            json_response = response.json()
            print(f"JSON Response: {json_response}")
        except:
            print(f"Raw Response: {response.text[:500]}...")

        return response.status_code in [200, 400, 401, 403]  # Valid responses
    except Exception as e:
        print(f"ERROR: {e}")
        return False


def test_with_different_endpoints():
    print("\n=== 4. OTHER ENDPOINTS TEST ===")
    endpoints = ["/admin/", "/api/admin/", "/static/"]

    for endpoint in endpoints:
        try:
            response = requests.get(f"{API_BASE}{endpoint}", timeout=10)
            print(f"{endpoint}: Status {response.status_code}")
        except Exception as e:
            print(f"{endpoint}: ERROR {e}")


def main():
    print("Django API Diagnostics")
    print("=" * 50)

    results = []
    results.append(test_connectivity())
    results.append(test_api_root())
    results.append(test_login_endpoint())
    test_with_different_endpoints()

    print("\n" + "=" * 50)
    print("SUMMARY:")
    print(f"Basic connectivity: {'✓' if results[0] else '✗'}")
    print(f"API root: {'✓' if results[1] else '✗'}")
    print(f"Login endpoint: {'✓' if results[2] else '✗'}")

    if not any(results):
        print("\n❌ API appears to be completely down")
        print("Possible issues:")
        print("- Server not running")
        print("- DNS/network issues")
        print("- Firewall blocking requests")
    elif results[0] and not results[1]:
        print("\n⚠️  Basic server works but API has issues")
        print("Possible issues:")
        print("- Django application crashed")
        print("- URL routing problems")
        print("- Python/Django errors")
    else:
        print("\n✅ Some endpoints respond - check specific errors above")


if __name__ == "__main__":
    main()
