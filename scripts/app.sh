#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y python3-pip python3-venv

mkdir -p /opt/app
cd /opt/app
python3 -m venv venv
source venv/bin/activate
pip install flask gunicorn psycopg2-binary

cat > /opt/app/app.py << 'PYEOF'
import os
import re
import hashlib
import secrets
import psycopg2
from psycopg2 import errors
from flask import Flask, request, jsonify

app = Flask(__name__)

DB_CONFIG = {
    "host": os.environ["DB_HOST"],
    "dbname": os.environ["DB_NAME"],
    "user": os.environ["DB_USER"],
    "password": os.environ["DB_PASSWORD"],
    "port": 5432,
}

EMAIL_RE = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")

def hash_password(password):
    salt = secrets.token_hex(16)
    digest = hashlib.sha256((salt + password).encode()).hexdigest()
    return f"{salt}$${digest}"

@app.get("/health")
def health():
    return "ok", 200

@app.post("/api/signup")
def signup():
    data = request.get_json(force=True)
    email = (data.get("email") or "").strip()
    password = data.get("password") or ""
    full_name = data.get("full_name") or ""

    if not EMAIL_RE.match(email):
        return jsonify({"error": "email invalide"}), 400
    if not password:
        return jsonify({"error": "mot de passe requis"}), 400

    password_hash = hash_password(password)

    try:
        conn = psycopg2.connect(**DB_CONFIG)
        cur = conn.cursor()
        cur.execute(
            "INSERT INTO users (email, password_hash, full_name) VALUES (%s, %s, %s)",
            (email, password_hash, full_name),
        )
        conn.commit()
        cur.close()
        conn.close()
    except errors.UniqueViolation:
        return jsonify({"error": "email déjà utilisé"}), 409
    except Exception as e:
        return jsonify({"error": str(e)}), 500

    return jsonify({"status": "created", "email": email}), 201

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PYEOF

cat > /etc/systemd/system/td-app.service << EOF
[Unit]
Description=TD App tier
After=network.target

[Service]
WorkingDirectory=/opt/app
Environment="DB_HOST=${db_host}"
Environment="DB_NAME=${db_name}"
Environment="DB_USER=${db_user}"
Environment="DB_PASSWORD=${db_password}"
ExecStart=/opt/app/venv/bin/gunicorn -b 0.0.0.0:80 app:app
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable td-app
systemctl start td-app
