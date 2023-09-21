# -*- coding: utf-8 -*-

"""
Module to provide for tests for the flask server.
"""

import json
import time
from typing import Any, Generator

import pytest

from flask_server import create_app


@pytest.fixture(name="app")
def fixture_app() -> Generator[Any, Any, Any]:
    """
    Generate the setup required to create the server within the context of the tests.
    """

    my_app = create_app()

    with my_app.app_context():
        # Setup
        pass

    yield my_app

    # Cleanup


@pytest.fixture(name="client")
def fixture_client(app: Any) -> Any:
    """
    Generate a client fixture to use to "call" the server.
    """
    return app.test_client()


@pytest.fixture(name="runner")
def fixture_runner(app: Any) -> Any:
    """
    Generate a runner fixture to test command line issues.
    """
    return app.test_cli_runner()


def test_simple_response(client: Any) -> None:
    """
    Make sure that we can get and process a simple response.
    """

    # Arrange
    relative_url = "/"

    # Act
    response = client.get(relative_url)
    decoded_response = response.data.decode("utf-8")
    json_response = json.loads(decoded_response)

    # Assert
    assert "message" in json_response
    assert isinstance(json_response["message"], str)
    assert "timestamp" in json_response
    assert isinstance(json_response["timestamp"], int)


def test_simple_response_with_delay(client: Any) -> None:
    """
    Make sure that the timestamp changes predictably.
    """

    # Arrange
    relative_url = "/"

    response = client.get(relative_url)
    decoded_response = response.data.decode("utf-8")
    json_response = json.loads(decoded_response)

    # Act
    time.sleep(1.9)

    response = client.get(relative_url)
    decoded_response = response.data.decode("utf-8")
    second_json_response = json.loads(decoded_response)

    # Assert
    assert json_response["message"] == second_json_response["message"]

    # Note that this should ALMOST always be 2, but just in case, give it a bit
    # of wiggle room.
    delta_in_seconds = second_json_response["timestamp"] - json_response["timestamp"]
    assert delta_in_seconds in [1, 2]
