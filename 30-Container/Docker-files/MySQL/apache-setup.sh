apt update
apt install apache2 -y -q
ufw allow 'Apache'
systemctl enable apache2
systemctl start apache2
a2enmod proxy
a2enmod proxy_http
a2enmod proxy_balancer
a2enmod lbmethod_byrequests
