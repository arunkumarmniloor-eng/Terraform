#!/bin/bash
#
## Update system
apt update -y
#
## Install dependencies
apt install -y python3 python3-pip nodejs npm git
#
## Clone repo (replace with your repo)
git clone https://github.com/arunkumarmniloor-eng/Terraform.git
cd YOUR_REPO
#
## ---------------- FLASK ----------------
cd flask-backend
pip3 install -r requirements.txt
nohup python3 app.py > flask.log 2>&1 &
#
## ---------------- EXPRESS ----------------
cd ../express-frontend
npm install
nohup node server.js > express.log 2>&1 &
