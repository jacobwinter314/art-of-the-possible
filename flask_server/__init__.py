#!/usr/bin/env python

from flask import Flask, jsonify, make_response
import time


def create_app():

    app = Flask(__name__)

    @app.route("/")
    def hello():
        d = {
            "message": "Automate all the things!",
            "timestamp": int(time.time())
        }
        return make_response(jsonify(d), 200)

    return app
