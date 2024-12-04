#!/bin/bash

set -e

# Variables
DB_PASSWORD="vamsi@123"
DVWA_DIR="/var/www/html/dvwa"
LOGSTASH_CONFIG="/etc/logstash/conf.d/apache_dvwa.conf"

echo "Updating and installing prerequisites..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php php-mysql php-gd libapache2-mod-php git wget apt-transport-https curl

# Install DVWA
echo "Installing DVWA..."
sudo git clone https://github.com/digininja/DVWA.git $DVWA_DIR
sudo chmod -R 755 $DVWA_DIR
sudo chown -R www-data:www-data $DVWA_DIR

echo "Configuring DVWA..."
sudo cp $DVWA_DIR/config/config.inc.php.dist $DVWA_DIR/config/config.inc.php
sudo sed -i "s/^\(\$_DVWA\['db_password'\] =\).*/\1 '$DB_PASSWORD';/" $DVWA_DIR/config/config.inc.php

echo "Setting up MySQL for DVWA..."
sudo systemctl start mysql
sudo mysql -u root <<MYSQL_SCRIPT
CREATE DATABASE dvwa;
CREATE USER 'root'@'localhost' IDENTIFIED BY '$DB_PASSWORD';
GRANT ALL PRIVILEGES ON dvwa.* TO 'root'@'localhost';
FLUSH PRIVILEGES;
MYSQL_SCRIPT

echo "Restarting Apache..."
sudo systemctl enable apache2
sudo systemctl restart apache2

# Install Elasticsearch
echo "Installing Elasticsearch..."
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee /etc/apt/sources.list.d/elastic-8.x.list
sudo apt update
sudo apt install -y elasticsearch
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch

# Install Logstash
echo "Installing Logstash..."
sudo apt install -y logstash
sudo systemctl enable logstash

# Install Kibana
echo "Installing Kibana..."
sudo apt install -y kibana
sudo systemctl enable kibana
sudo systemctl start kibana

# Configure Logstash
echo "Configuring Logstash..."
sudo mkdir -p $(dirname $LOGSTASH_CONFIG)
sudo tee $LOGSTASH_CONFIG > /dev/null <<EOL
input {
    file {
        path => "/var/log/apache2/access.log"
        start_position => "beginning"
        sincedb_path => "/dev/null"
    }
}

filter {
    grok {
        match => { "message" => "%{COMBINEDAPACHELOG}" }
    }
    date {
        match => [ "timestamp" , "dd/MMM/yyyy:HH:mm:ss Z" ]
        target => "@timestamp"
    }
}

output {
    elasticsearch {
        hosts => ["http://localhost:9200"]
        index => "dvwa-logs"
    }
    stdout { codec => rubydebug }
}
EOL

echo "Starting Logstash..."
sudo systemctl restart logstash

# Kibana Configuration
echo "Configuring Kibana..."
echo "Kibana is available at: http://<your-ip>:5601"

# Final Steps
echo "DVWA is available at: http://<your-ip>/dvwa"
echo "Default credentials: admin / password"
echo "Please login and click 'Create / Reset Database' to complete DVWA setup."
