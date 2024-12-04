What the Script Does
Installs DVWA:
Downloads and configures DVWA under /var/www/html/dvwa.
Sets the MySQL root password to vamsi@123.
Sets Up ELK Stack:
Installs Elasticsearch, Logstash, and Kibana.
Configures Logstash to monitor Apache logs (/var/log/apache2/access.log).
Configures Kibana:
Kibana will be accessible at http://<your-ip>:5601.
Post-Setup
Access DVWA:

Navigate to http://<kali-ip>/dvwa.
Log in with admin / password.
Click "Create / Reset Database" in the setup tab.
Access Kibana:

Navigate to http://<kali-ip>:5601.
Create an index pattern (dvwa-logs*) to visualize the logs.
Generate Logs:

Interact with DVWA to create logs (e.g., SQL Injection, XSS).
Logs will be available in Kibana's Discover section.
