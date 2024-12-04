#!/bin/bash

# Exit on any error
set -e

# Install Docker if not installed
if ! command -v docker &> /dev/null
then
    echo "Docker not found, installing Docker..."
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl software-properties-common
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
    sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
    sudo apt-get update
    sudo apt-get install -y docker-ce
    sudo systemctl enable --now docker
else
    echo "Docker already installed."
fi

# Run Juice Shop in Docker
echo "Running OWASP Juice Shop in Docker..."
sudo docker pull bkimminich/juice-shop
sudo docker run --rm -d -p 3000:3000 --name juice-shop bkimminich/juice-shop

# Install Java (required for Elasticsearch)
echo "Installing Java for Elasticsearch..."
sudo apt-get install -y openjdk-11-jdk

# Install and configure Elasticsearch
echo "Installing Elasticsearch..."
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-8.6.2-linux-x86_64.tar.gz
tar -xzvf elasticsearch-8.6.2-linux-x86_64.tar.gz
cd elasticsearch-8.6.2
sudo ./bin/elasticsearch &
sleep 15 # Give Elasticsearch time to start

# Install and configure Kibana
echo "Installing Kibana..."
cd ..
wget https://artifacts.elastic.co/downloads/kibana/kibana-8.6.2-linux-x86_64.tar.gz
tar -xzvf kibana-8.6.2-linux-x86_64.tar.gz
cd kibana-8.6.2
sudo ./bin/kibana &
sleep 15 # Give Kibana time to start

# Install and configure Logstash
echo "Installing Logstash..."
cd ..
wget https://artifacts.elastic.co/downloads/logstash/logstash-8.6.2-linux-x86_64.tar.gz
tar -xzvf logstash-8.6.2-linux-x86_64.tar.gz
cd logstash-8.6.2

# Create a Logstash config file to monitor Juice Shop logs
echo "Creating Logstash config file..."
sudo mkdir -p /etc/logstash/conf.d
cat <<EOL | sudo tee /etc/logstash/conf.d/juice_shop_logs.conf > /dev/null
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
        index => "juice-shop-logs"
    }
    stdout { codec => rubydebug }
}
EOL

# Start Logstash with the new configuration
echo "Starting Logstash..."
sudo ./bin/logstash -f /etc/logstash/conf.d/juice_shop_logs.conf &
sleep 15 # Give Logstash time to start

# Configure Kibana index pattern
echo "Kibana setup complete. Now you can configure your index pattern in Kibana..."
echo "Go to Kibana at http://localhost:5601"
echo "In Kibana, create an index pattern for 'juice-shop-logs*'"

# Final Message
echo "OWASP Juice Shop is now running at http://localhost:3000"
echo "You can view logs and create visualizations in Kibana at http://localhost:5601"
echo "For Kibana, use the index pattern 'juice-shop-logs*' to view Juice Shop logs."

