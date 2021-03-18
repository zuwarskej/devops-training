#!/bin/bash
export DEBIAN_FRONTEND=noninteractive

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

INFO "Install Nginx"
apt-get install -y nginx > /dev/null 2>&1

INFO "Stop Nginx Service"
systemctl stop nginx

INFO "Create & Copy Config File"
rm -rf /etc/nginx/sites-enabled/default
touch /etc/nginx/sites-enabled/default

FILE=/etc/nginx/sites-enabled/default
cat <<EOF > $FILE
upstream backend {
        server 172.16.10.11:8080;    # web-1.local
        server 172.16.10.12:8080;    # web-2.local
}
server {
        listen 80 default_server;
        listen [::]:80 default_server ipv6only=on;
        root /usr/share/nginx/html;
        index index.html index.htm;
        
        # Make site accessible from http://localhost/
        server_name localhost;
        location / {
                proxy_pass http://backend;
        }
}
EOF

INFO "Restart Nginx"
systemctl start nginx

INFO "Check Answer from Nginx"
curl -Is http://localhost:80 | head -n 1