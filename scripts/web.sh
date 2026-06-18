#!/bin/bash
set -e
export DEBIAN_FRONTEND=noninteractive

apt-get update -y
apt-get install -y python3-pip python3-venv

mkdir -p /opt/web
cd /opt/web
python3 -m venv venv
source venv/bin/activate
pip install flask gunicorn requests

cat > /opt/web/web.py << 'PYEOF'
import os
import requests
from flask import Flask, request, render_template_string

app = Flask(__name__)
APP_API_URL = f"http://{os.environ['INTERNAL_ALB_DNS']}/api/signup"

FORM = """
<!doctype html><title>Inscription</title>
<h1>Créer un compte</h1>
<form method="post" action="/signup">
  <input name="full_name" placeholder="Nom complet"><br>
  <input name="email" type="email" placeholder="Email" required><br>
  <input name="password" type="password" placeholder="Mot de passe" required><br>
  <button type="submit">S'inscrire</button>
</form>
"""

RESULT_OK = "<!doctype html><title>Inscription</title><h1>Compte créé</h1><p>Bienvenue {{full_name}} ({{email}}) !</p>"
RESULT_ERR = "<!doctype html><title>Inscription</title><h1>Erreur</h1><p>{{message}}</p>"

@app.get("/health")
def health():
    return "ok", 200

@app.get("/")
def form():
    return render_template_string(FORM)

@app.post("/signup")
def signup():
    full_name = request.form.get("full_name", "")
    email = request.form.get("email", "")
    password = request.form.get("password", "")

    try:
        resp = requests.post(APP_API_URL, json={"full_name": full_name, "email": email, "password": password}, timeout=5)
    except requests.RequestException:
        return render_template_string(RESULT_ERR, message="API indisponible, réessayez plus tard."), 502

    if resp.status_code == 201:
        return render_template_string(RESULT_OK, full_name=full_name, email=email)
    elif resp.status_code == 409:
        return render_template_string(RESULT_ERR, message="Cet email est déjà utilisé."), 409
    elif resp.status_code == 400:
        return render_template_string(RESULT_ERR, message="Données invalides."), 400
    else:
        return render_template_string(RESULT_ERR, message="Erreur serveur."), 500

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=80)
PYEOF

cat > /etc/systemd/system/td-web.service << EOF
[Unit]
Description=TD Web tier
After=network.target

[Service]
WorkingDirectory=/opt/web
Environment="INTERNAL_ALB_DNS=${internal_alb_dns}"
ExecStart=/opt/web/venv/bin/gunicorn -b 0.0.0.0:80 web:app
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable td-web
systemctl start td-web
