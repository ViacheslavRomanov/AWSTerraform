#!/bin/bash

source ../vars/env_vars # AWS Credentials & region
export TF_VAR_jenkins_public_keyfile="../vars/aws_key.pub" #path to pubkey
export TF_VAR_jenkins_private_keyfile="~/.ssh/aws_key" #path to privkey
packer build jenkins.json && terraform init && terraform plan -input=false -out=tfplan

if [ -f tfplan ]
then
    terraform apply -input=false tfplan
fi

if [ -f my_env ]
then
    echo "...delay 5m"
    sleep 5m # jenkins lags
    source my_env
    echo $JENKINS_SERVER_IP
    INITIAL_PASSWORD=`ssh -i $TF_VAR_jenkins_private_keyfile -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP sudo cat /var/lib/jenkins/secrets/initialAdminPassword`
    echo "Password is $INITIAL_PASSWORD"
    echo "login to jenkins http://$JENKINS_SERVER_IP:8080"
    echo
fi
PASS=$INITIAL_PASSWORD
function jcli_cred () {
    ssh -i $TF_VAR_jenkins_private_keyfile -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$PASS create-credentials-by-xml system::system::jenkins _ $1
}

function jcli_jobs () {
    ssh -i $TF_VAR_jenkins_private_keyfile -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$PASS create-job $1 < xmljobs/$1.xml
}

function jcli_build () {
    ssh -i $TF_VAR_jenkins_private_keyfile -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP sudo java -jar /var/lib/jenkins/jenkins-cli.jar -s http://localhost:8080 -auth admin:$PASS build $1 -s
}

cred/aws_key_id.sh  | jcli_cred
cred/aws_sec_key.sh  | jcli_cred
CRUMB=$(curl -s "http://admin:"${PASS}"@"${JENKINS_SERVER_IP}":8080/crumbIssuer/api/xml?xpath=concat(//crumbRequestField,\":\",//crumb)")
curl -H $CRUMB -X POST "http://admin:"${PASS}"@"${JENKINS_SERVER_IP}":8080/credentials/store/system/domain/_/createCredentials" \
  -F secret=@$TF_VAR_jenkins_public_keyfile \
  -F 'json={ "": "0",
             "credentials":{
                "scope": "GLOBAL",
                "file": "secret",
                "id": "ec2_aws_pub",
                "stapler-class": "org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl",
                "$class": "org.jenkinsci.plugins.plaincredentials.impl.FileCredentialsImpl"
             }
           }'

jcli_jobs app_ami_update
jcli_jobs create_app_image
jcli_jobs create_base_image
jcli_jobs create_aws_infrastructure
ssh -i $TF_VAR_jenkins_private_keyfile -o "StrictHostKeyChecking no" ec2-user@$JENKINS_SERVER_IP "echo $PASS | sudo tee /var/lib/jenkins/secrets/initialAdminPassword"
jcli_build create_aws_infrastructure

cd appenv
terraform init && terraform plan -input=false -out=tfplan

if [ -f tfplan ]
then
    terraform apply -input=false tfplan > result.out   && terraform destroy -auto-approve
    cat result.out
    echo "Password is $INITIAL_PASSWORD"
    echo "login to jenkins http://$JENKINS_SERVER_IP:8080"
fi
