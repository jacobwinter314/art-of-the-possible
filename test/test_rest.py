
import json
import pytest
from flask_server import create_app
import time

@pytest.fixture
def app():
    app = create_app()

    with app.app_context():
        # Setup
        pass

    yield app

    # Cleanup
    pass


@pytest.fixture
def client(app):
    return app.test_client()


@pytest.fixture
def runner(app):
    return app.test_cli_runner()

def test_simple_response(client):
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
    assert 'message' in json_response
    assert isinstance(json_response['message'], str)
    assert 'timestamp' in json_response
    assert isinstance(json_response['timestamp'], int)

def test_simple_response_with_delay(client):
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
    assert delta_in_seconds in [1,2]
