#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
export TOMCAT_VERSION=9.0.44

# Define some fuctions
INFO(){ echo "INFO: $*";}
WARN(){ echo "WARN: $*";}
ERRO(){ echo "ERRO: $*"; exit 1;}

INFO "Download & Install Java"
apt-get install openjdk-11-jdk -y > /dev/null 2>&1

INFO "Download, Extract Tomcat & Change Permissions Tomcat"
groupadd tomcat
cd /tmp
wget -q https://downloads.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz
mkdir /opt/tomcat
tar xzvf /tmp/apache-tomcat-${TOMCAT_VERSION}.tar.gz -C /opt/tomcat --strip-components=1
cd /opt/tomcat
chmod -R 777 /opt/tomcat
cp /vagrant/tomcat.service /etc/systemd/system/tomcat.service

INFO "Add User & Change File Locking Configuration Tomcat"
sed -i 's|</tomcat-users>|<user username="admin" password="password" roles="manager-gui,admin-gui"/></tomcat-users>|' /opt/tomcat/conf/tomcat-users.xml
sed -i 's|<Context antiResourceLocking="false" privileged="true" >|<Context antiResourceLocking="false" privileged="true" ><!--|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i 's|</Context>|--></Context>|' /opt/tomcat/webapps/manager/META-INF/context.xml
sed -i 's|<Context antiResourceLocking="false" privileged="true" >|<Context antiResourceLocking="false" privileged="true" ><!--|' /opt/tomcat/webapps/host-manager/META-INF/context.xml
sed -i 's|</Context>|--></Context>|' /opt/tomcat/webapps/host-manager/META-INF/context.xml

INFO "Start Tomcat"
systemctl daemon-reload
systemctl enable tomcat
systemctl restart tomcat

INFO "Check Answer from Tomcat"
curl -Is http://localhost:8080 | head -n 1