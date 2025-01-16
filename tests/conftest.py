"""Test configuration and fixtures."""

import os

import pytest


@pytest.fixture
def proxy_url():
    """Return the URL of the proxy service."""
    proxy_host = os.getenv("PROXY_HOST", "localhost")
    proxy_port = os.getenv("PROXY_PORT", "8080")
    return f"http://{proxy_host}:{proxy_port}"
