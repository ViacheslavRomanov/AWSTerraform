#!/usr/bin/env bash

source ../../.env_vars # AWS Credentials & region
export TF_VAR_jenkins_pub_key="../vars/aws_key.pub" #path to pubkey
packer build jenkins.json &&terraform init && terraform plan -input=false -out=tfplan

if [ -f tfplan ]
then
    terraform apply -input=false tfplan
fi

if [ -f my_env ]
then
    echo "...delay 30s"
    sleep 30
    source my_env
    INITIAL_PASSWORD=`ssh -i ~/.ssh/aws_key -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
    echo "Password is $INITIAL_PASSWORD"
    echo "login to jenkins http://$JENKINS_SERVER_IP:8080"
fi
