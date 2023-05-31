#!/bin/bash

# Update system packages
apt-get update

# Install PHP 8
apt install ca-certificates apt-transport-https
wget -q https://packages.sury.org/php/apt.gpg -O- | apt-key add -
echo "deb https://packages.sury.org/php/ $(lsb_release -sc) main" | tee /etc/apt/sources.list.d/php.list
apt-get update
apt-get install -y php8.0 php8.0-cli php8.0-common php8.0-curl php8.0-mbstring php8.0-mysql php8.0-xml php8.0-zip php8.0-gd

# Install MariaDB
apt-get install -y mariadb-server

# Install Apache
apt-get install -y apache2

# Enable required Apache modules
a2enmod rewrite
a2enmod php8.0
a2enmod ssl

# Generate a self-signed SSL certificate
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/localhost.key -out /etc/ssl/certs/localhost.crt <<EOF
US
California
San Francisco
My Company
IT Department
localhost
myemail@localhost.com
EOF

# Create Apache virtual host configuration for HTTPS
cat <<EOF | tee /etc/apache2/sites-available/localhost-ssl.conf
<VirtualHost *:443>
    ServerName localhost
    DocumentRoot /var/www/html

    SSLEngine on
    SSLCertificateFile /etc/ssl/certs/localhost.crt
    SSLCertificateKeyFile /etc/ssl/private/localhost.key

    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF

# Enable the HTTPS virtual host
a2ensite localhost-ssl.conf

# Start services
service apache2 start
service mariadb start

# Secure MariaDB installation
mysql_secure_installation

echo "PHP 8, MariaDB, and Apache have been installed successfully."
