#!/bin/bash

apt update -y
apt install -y nginx curl

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
  <title>TD3 Web</title>
</head>
<body>
  <h1>Web Tier OK</h1>
  <p>App backend: ${app_ip}:5000</p>
</body>
</html>
EOF

systemctl enable nginx
systemctl restart nginx
