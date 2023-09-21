#!/usr/bin/env python
# -*- coding: utf-8 -*-

"""
Module to implement a very simple flask server.
"""

import time

from flask import Flask, Response, jsonify, make_response


def create_app() -> Flask:
    """
    Create the application hosting the flask server.
    """

    app = Flask(__name__)

    @app.route("/")
    def base_route() -> Response:
        """
        Respond to a request at the base route for the server.
        """
        response_dictionary = {
            "message": "Automate all the things!",
            "timestamp": int(time.time()),
        }
        return make_response(jsonify(response_dictionary), 200)

    return app
