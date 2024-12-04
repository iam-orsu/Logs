# Logs

Step 1: Install Prerequisites
Update your system and install essential tools:

bash
Copy code
sudo apt update && sudo apt upgrade -y
sudo apt install -y apache2 mysql-server php php-mysql php-gd libapache2-mod-php git wget apt-transport-https curl
Step 2: Set Up DVWA on Kali
2.1. Download DVWA
Clone the DVWA repository:

bash
Copy code
git clone https://github.com/digininja/DVWA.git /var/www/html/dvwa
Set permissions:

bash
Copy code
sudo chmod -R 755 /var/www/html/dvwa
sudo chown -R www-data:www-data /var/www/html/dvwa
2.2. Configure DVWA
Create the configuration file:

bash
Copy code
cp /var/www/html/dvwa/config/config.inc.php.dist /var/www/html/dvwa/config/config.inc.php
Edit the configuration file:

bash
Copy code
nano /var/www/html/dvwa/config/config.inc.php
Set the database details:

php
Copy code
$_DVWA['db_user'] = 'root';
$_DVWA['db_password'] = ''; // Use MySQL root password if set
2.3. Set Up the Database
Start MySQL:

bash
Copy code
sudo systemctl start mysql
Create the DVWA database:

bash
Copy code
mysql -u root -p
Run the following SQL commands:

sql
Copy code
CREATE DATABASE dvwa;
GRANT ALL PRIVILEGES ON dvwa.* TO 'root'@'localhost' IDENTIFIED BY '';
FLUSH PRIVILEGES;
EXIT;
2.4. Start Apache
Enable and start Apache:

bash
Copy code
sudo systemctl enable apache2
sudo systemctl start apache2
Test DVWA:

Open a browser and navigate to http://<kali-ip>/dvwa.
Log in with default credentials: admin / password.
Go to the Setup tab and click Create / Reset Database.
Step 3: Install the ELK Stack on Kali
3.1. Install Elasticsearch
Import the Elasticsearch GPG key:

bash
Copy code
wget -qO - https://artifacts.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -
Add the Elastic repository:

bash
Copy code
echo "deb https://artifacts.elastic.co/packages/8.x/apt stable main" | sudo tee -a /etc/apt/sources.list.d/elastic-8.x.list
Install Elasticsearch:

bash
Copy code
sudo apt update
sudo apt install elasticsearch -y
Start Elasticsearch:

bash
Copy code
sudo systemctl enable elasticsearch
sudo systemctl start elasticsearch
Verify it’s running:

bash
Copy code
curl -X GET "localhost:9200/"
3.2. Install Logstash
Install Logstash:

bash
Copy code
sudo apt install logstash -y
Start Logstash:

bash
Copy code
sudo systemctl enable logstash
sudo systemctl start logstash
3.3. Install Kibana
Install Kibana:

bash
Copy code
sudo apt install kibana -y
Start Kibana:

bash
Copy code
sudo systemctl enable kibana
sudo systemctl start kibana
Open Kibana in your browser: Navigate to http://<kali-ip>:5601.

Step 4: Configure Logstash to Monitor DVWA Logs
4.1. Create a Logstash Configuration File
Create a new Logstash pipeline:

bash
Copy code
sudo nano /etc/logstash/conf.d/apache_dvwa.conf
Add the following configuration:

bash
Copy code
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
Test the configuration:

bash
Copy code
sudo /usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/apache_dvwa.conf --config.test_and_exit
Restart Logstash:

bash
Copy code
sudo systemctl restart logstash
Step 5: Configure Kibana to Visualize DVWA Logs
Open Kibana (http://<kali-ip>:5601) and log in.
Navigate to Stack Management > Index Patterns.
Create a new index pattern:
Index name: dvwa-logs*.
Time filter field: @timestamp.
Save the index pattern.
Step 6: Test the Setup
Interact with DVWA (e.g., try SQL Injection or XSS).

Check /var/log/apache2/access.log to see generated logs:

bash
Copy code
tail -f /var/log/apache2/access.log
Verify logs are ingested in Elasticsearch:

bash
Copy code
curl -X GET "localhost:9200/dvwa-logs/_search?pretty"
View logs in Kibana:

Go to Discover.
Select your dvwa-logs index pattern to see the logs.
