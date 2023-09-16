#!/bin/bash

# Reference
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
