"""Utility functions for testing."""

import json


def print_debug_info(response):
    """Print debug information for a failed response."""
    try:
        body = response.json()
    except json.JSONDecodeError:
        body = response.text

    print(f"Status code: {response.status_code}")
    print(f"Headers: {response.headers}")
    print(f"Body: {body}")


def verify_headers(received_headers, expected_present, expected_absent):
    """Verify that headers match expectations."""
    # Check that expected headers are present with correct values
    for header, value in expected_present.items():
        assert header.lower() in {k.lower() for k in received_headers.keys()}, f"Missing header: {header}"
        assert any(
            v == value for k, v in received_headers.items() if k.lower() == header.lower()
        ), f"Header {header} has wrong value. Expected {value}"

    # Check that certain headers are not present
    present_headers = {k.lower() for k in received_headers.keys()}
    for header in expected_absent:
        assert header.lower() not in present_headers, f"Header should not be present: {header}"


def print_request_debug(response, request_body, request_headers):
    """Print debug information for a failed request."""
    print(f"Request body: {request_body}")
    print(f"Request headers: {request_headers}")
    print_debug_info(response)
