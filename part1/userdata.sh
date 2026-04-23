#!/bin/bash
apt update -y
#
## Install Python + Flask
apt install python3-pip -y
pip3 install flask
#
## Install Node.js
curl -fsSL https://deb.nodesource.com/setup_18.x | bash -
apt install -y nodejs
#
## Flask App
cat <<EOF > app.py
from flask import Flask
app = Flask(__name__)
#
@app.route("/")
def home():
    return "Flask Backend Running"
#
    app.run(host="0.0.0.0", port=5000)
    EOF
#
#    # Express App
    mkdir express-app
    cd express-app
#
    cat <<EOF > app.js
    const express = require('express');
    const app = express();
#
    app.get('/', (req, res) => {
      res.send('Express Frontend Running');
      });
#
      app.listen(3000, '0.0.0.0');
      EOF
#
      npm init -y
      npm install express
#
#      # Run apps
      nohup python3 app.py &
      nohup node app.js &
