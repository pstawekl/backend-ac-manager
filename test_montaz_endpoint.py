#!/usr/bin/env python
"""
Simple test script to check if the montaz_create endpoint is accessible
"""
from klima.views import MontazCreateApiView
from django.urls import resolve, reverse
from django.test import Client
import os
import sys

import django

# Add the project directory to Python path
sys.path.append(os.path.dirname(os.path.abspath(__file__)))

# Setup Django environment
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'ACManager.settings')
django.setup()


def test_montaz_endpoint():
    print("Testing montaz_create endpoint...")

    # Test 1: Check if URL can be resolved
    try:
        url = reverse('montaz_create')
        print(f"✓ URL resolved successfully: {url}")
    except Exception as e:
        print(f"✗ URL resolution failed: {e}")
        return

    # Test 2: Check if view can be resolved from URL
    try:
        resolver_match = resolve('/api/montaz_create/')
        print(f"✓ View resolved successfully: {resolver_match.func.cls}")
    except Exception as e:
        print(f"✗ View resolution failed: {e}")
        return

    # Test 3: Check if view class exists
    try:
        view = MontazCreateApiView()
        print(f"✓ View class instantiated successfully: {view}")
    except Exception as e:
        print(f"✗ View class instantiation failed: {e}")
        return

    print("All tests passed! The endpoint should be working.")
    print("If you're still getting 404, try restarting the Django server.")


if __name__ == "__main__":
    test_montaz_endpoint()
