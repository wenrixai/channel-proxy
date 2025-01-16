"""Tests for the proxy functionality."""

import requests
from test_utils import print_debug_info, print_request_debug, verify_headers


def test_proxy_health(proxy_url):
    """Test that proxy is up and responding."""
    response = requests.get(f"{proxy_url}/")
    if response.status_code != 200:
        print_debug_info(response)
    assert response.status_code == 200
    assert "Welcome to Wenrix Proxy" in response.text


def test_ba_request(proxy_url):
    """Test that BA proxy correctly handles the request."""
    test_headers = {
        "x-wenrix-operation": "should-be-removed",
        "x-wenrix-trace-id": "should-be-removed",
        "authorization": "should-be-removed",
        "test-header": "should-remain",
    }

    response = requests.get(f"{proxy_url}/channel/britishairways/anything", headers=test_headers)
    if response.status_code != 200:
        print_debug_info(response)
    assert response.status_code == 200

    # httpbin /anything endpoint returns details about the request it received
    request_info = response.json()
    received_headers = request_info["headers"]

    # Verify headers were properly handled
    verify_headers(
        received_headers,
        expected_present={"Test-Header": "should-remain", "Client-Key": "test-ba-key"},
        expected_absent=["X-Wenrix-Operation", "X-Wenrix-Trace-Id", "Authorization"],
    )

    # Verify the URL path was properly forwarded
    assert request_info["url"].endswith("/anything")


def test_farelogix_aa_request(proxy_url):
    """Test that Farelogix AA proxy correctly handles the request."""
    test_body = {
        "username": "#FLX_USERNAME#",
        "password": "#FLX_PASSWORD#",
        "agent": "#FLX_AGENT#",
        "agentUser": "#FLX_AGENT_USER#",
        "agentPassword": "#FLX_AGENT_PASSWORD#",
        "otherField": "unchanged",
    }

    request_headers = {"test-header": "should-remain"}

    response = requests.post(f"{proxy_url}/channel/farelogix-aa/anything", json=test_body, headers=request_headers)
    if response.status_code != 200:
        print_request_debug(response, test_body, request_headers)
    assert response.status_code == 200

    # Get request details from httpbin
    request_info = response.json()

    # Verify headers
    verify_headers(
        request_info["headers"],
        expected_present={"Test-Header": "should-remain", "Ocp-Apim-Subscription-Key": "test-aa-key"},
        expected_absent=[],
    )

    # Verify body transformations
    received_body = request_info["json"]
    assert received_body["username"] == "test-user"
    assert received_body["password"] == "test-pass"
    assert received_body["agent"] == "test-agent"
    assert received_body["agentUser"] == "test-agent-user"
    assert received_body["agentPassword"] == "test-agent-pass"
    assert received_body["otherField"] == "unchanged"  # Verify unchanged fields

    # Verify URL path
    assert request_info["url"].endswith("/anything")
