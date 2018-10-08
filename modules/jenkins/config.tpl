#!/bin/bash
set -e -x

function waitForJenkins() {
    echo "[INFO] Wait for jenkins localhost:8080..."
    while ! nc -z localhost 8080; do
      sleep 1
    done
    echo "[INFO] ... jenkins launched"
}

function waitForPasswordFile() {
    echo "[INFO] Wait for initialAdminPassword..."
    while [ ! -f /var/lib/jenkins/secrets/initialAdminPassword ]; do
      sleep 2
    done
    echo "[INFO] ...password created"
}

sudo service jenkins start
sudo chkconfig --add jenkins

waitForJenkins

# UPDATE PLUGIN LIST

curl  -L http://updates.jenkins-ci.org/update-center.json | sed '1d;$d' | curl -X POST -H 'Accept: application/json' -d @- http://localhost:8080/updateCenter/byId/default/postBack

sleep 10

waitForJenkins

# INSTALL CLI
sudo cp /var/cache/jenkins/war/WEB-INF/jenkins-cli.jar /var/lib/jenkins/jenkins-cli.jar

waitForPasswordFile

PASS=$(sudo bash -c "cat /var/lib/jenkins/secrets/initialAdminPassword")

sleep 10


xmlstarlet ed -u "//slaveAgentPort" -v "${jnlp_port}" /var/lib/jenkins/config.xml > /tmp/jenkins_config.xml
sudo mv /tmp/jenkins_config.xml /var/lib/jenkins/config.xml
sudo service jenkins restart

waitForJenkins

sleep 10

sudo cat << EOF | sudo tee /var/lib/jenkins/jenkins.CLI.xml
<?xml version='1.1' encoding='UTF-8'?>
<jenkins.CLI>
  <enabled>true</enabled>
</jenkins.CLI>

EOF

#sleep 10 # morning timeout
sleep 5m # evening timeout :)

sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$PASS install-plugin ${plugins}
sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$PASS restart
javac -version
java -version




