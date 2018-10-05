#!/bin/sh

sudo yum -y update
sudo yum install -y java-1.8.0-openjdk.x86_64
sudo yum install -y java-1.8.0-openjdk-devel.x86_64
sudo yum install -y dos2unix

sudo /usr/sbin/alternatives --set java /usr/lib/jvm/jre-1.8.0-openjdk.x86_64/bin/java
sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac

sudo yum remove -y java-1.7*
sudo yum install -y git nginx aws-cli


# install maven
sudo wget http://repos.fedorapeople.org/repos/dchen/apache-maven/epel-apache-maven.repo -O /etc/yum.repos.d/epel-apache-maven.repo
sudo sed -i s/\$releasever/6/g /etc/yum.repos.d/epel-apache-maven.repo
sudo yum install -y apache-maven
mvn –v

sudo yum install -y xmlstarlet

# install jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo http://pkg.jenkins-ci.org/redhat/jenkins.repo
sudo rpm --import http://pkg.jenkins-ci.org/redhat/jenkins-ci.org.key
sudo yum install -y jenkins
sudo chkconfig jenkins on

#install terraform
cd /usr/local/src
sudo wget https://releases.hashicorp.com/terraform/0.11.8/terraform_0.11.8_linux_amd64.zip
sudo unzip terraform_0.11.8_linux_amd64.zip
sudo mv terraform /bin
terraform --version

#install packer
cd /usr/local/src
sudo wget https://releases.hashicorp.com/packer/1.3.1/packer_1.3.1_linux_amd64.zip
sudo unzip packer_1.3.1_linux_amd64.zip
sudo mv packer /bin
packer --version


sudo /usr/sbin/alternatives --set javac /usr/lib/jvm/java-1.8.0-openjdk.x86_64/bin/javac



