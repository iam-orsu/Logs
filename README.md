How to Use the Script:
Save the Script: Save the script to a file named setup_juice_shop_elk.sh:

bash
Copy code
nano setup_juice_shop_elk.sh
Make the Script Executable:

bash
Copy code
chmod +x setup_juice_shop_elk.sh
Run the Script:

bash
Copy code
sudo ./setup_juice_shop_elk.sh
What the Script Does:
Installs Docker (if not already installed) and runs OWASP Juice Shop in a Docker container.
Installs Elasticsearch, Kibana, and Logstash manually.
Configures Logstash to read Apache logs (you may need to adjust the log file path if Juice Shop isn't logging to Apache's default log location) and send them to Elasticsearch.
Runs Kibana to visualize the logs.
Once the script is executed, you can access Juice Shop at http://localhost:3000 and Kibana at http://localhost:5601.
After Running the Script:
Access OWASP Juice Shop:

Open your browser and go to http://localhost:3000. This will be the Juice Shop application.
Access Kibana:

Open your browser and go to http://localhost:5601.
In Kibana, go to Stack Management > Index Patterns, and create an index pattern juice-shop-logs* to visualize the logs.
Explore logs under Discover and create visualizations in Kibana.
View Logs in Kibana:

Once you interact with the Juice Shop, you will see logs being collected in Elasticsearch and visualized in Kibana.
