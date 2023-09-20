#!/usr/bin/env python

from flask import Flask, jsonify, make_response
import time

app = Flask(__name__)

@app.route("/")
def hello():
    d = {
        "message": "Automate all the things!",
        "timestamp": int(time.time())
    }
    return make_response(jsonify(d), 200)

# Runs on port 5000 by default
if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5001)
