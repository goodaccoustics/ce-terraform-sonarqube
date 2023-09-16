#!/bin/bash

# References
# https://blog.devops.dev/how-to-install-sonarqube-on-linux-rhel-centos-57eb5893be
# https://github.com/raj13aug/sonarqube_ec2/blob/main/sonar_script.sh

# update linux packages
sudo apt-get update -y

# install dependencies
sudo apt-get install wget unzip -y
sudo apt-get install openjdk-17-jdk -y

# install postgreSQL
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -
sudo apt-get install postgresql-14 -y
sudo systemctl enable postgresql.service
sudo systemctl start postgresql.service

# create a user with sonar:admin123 in postgreSQL database
sudo echo "postgres:admin123" | chpasswd
runuser -l postgres -c "createuser sonar"

# create a database and table in postgreSQL database
sudo -i -u postgres psql -c "ALTER USER sonar WITH ENCRYPTED PASSWORD 'admin123';"
sudo -i -u postgres psql -c "CREATE DATABASE sonarqube OWNER sonar;"
sudo -i -u postgres psql -c "GRANT ALL PRIVILEGES ON DATABASE sonarqube to sonar;"
sudo systemctl restart postgresql

# install sonarqube
sudo mkdir -p /tmp/sonarqube/
cd /tmp/sonarqube/
sudo curl -O https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-9.9.0.65466.zip
sudo apt-get install zip -y
sudo unzip -o sonarqube-9.9.0.65466.zip -d /opt/
sudo mv /opt/sonarqube-9.9.0.65466/ /opt/sonarqube

# add postgreSQL user credentials into sonarqube configs
sudo rm -rf /opt/sonarqube/conf/sonar.properties
sudo touch /opt/sonarqube/conf/sonar.properties
sudo bash -c 'cat <<EOT> /opt/sonarqube/conf/sonar.properties
sonar.jdbc.username=sonar
sonar.jdbc.password=admin123
sonar.jdbc.url=jdbc:postgresql://localhost/sonarqube
sonar.web.host=0.0.0.0
sonar.web.port=9000
sonar.web.javaAdditionalOpts=-server
sonar.search.javaOpts=-Xmx512m -Xms512m -XX:+HeapDumpOnOutOfMemoryError
sonar.log.level=INFO
sonar.path.logs=logs
EOT'

# create group
sudo groupadd sonar
sudo useradd -c "SonarQube - User" -d /opt/sonarqube/ -g sonar sonar
sudo chown sonar:sonar /opt/sonarqube/ -R


# create a systemd service file for sonarqube to run at system startup
sudo touch /etc/systemd/system/sonar.service
sudo bash -c 'cat <<EOT> /etc/systemd/system/sonarqube.service
[Unit] 
Description=SonarQube service 
After=syslog.target network.target 

[Service] 
Type=forking 
ExecStart=/opt/sonarqube/bin/linux-x86-64/sonar.sh start 
ExecStop=/opt/sonarqube/bin/linux-x86-64/sonar.sh stop 
User=sonar 
Group=sonar 
Restart=always 

[Install] 
WantedBy=multi-user.target
EOT'

# reload the new systemd service for sonarqube created above
sudo systemctl daemon-reload
sudo systemctl enable sonarqube.service