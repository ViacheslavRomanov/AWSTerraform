pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_key')
        TF_VAR_aws_region = "${AWS_REGION}"
        TF_VAR_db_name = "${DB_NAME}"
        TF_VAR_db_user = "${DB_USER}"
        TF_VAR_db_password = "${DB_PASSWORD}"
    }
    stages {
        stage('Create base image') {
            steps {
                build job: 'create_base_image', parameters: [
                        string(name: 'AWS_REGION', value: "${AWS_REGION}")
                ]
            }
        }
        stage('Create app AMI') {
            steps {
                build job: 'create_app_image', parameters: [
                        string(name: 'AWS_REGION', value: "${AWS_REGION}")
                ]
            }
        }
        stage('Checkout') {
            steps {
                checkout scm
            }
        }
        stage('Init') {
            steps {
                dir ('stage') {
                    sh 'terraform init'
                }
            }
        }
        stage('Plan') {
            steps {
                withCredentials([
                        file(credentialsId: 'ec2_aws_pub', variable: 'KEY_PATH')
                ]) {
                    dir('stage') {
                        sh "cp ${KEY_PATH} aws_pub.key"
                        sh "export TF_VAR_ec2_key_path='aws_pub.key'; terraform plan -input=false -out=tfplan"
                        sh "rm aws_pub.key"
                    }
                }
            }
        }
        stage('Apply') {
            steps {
                withCredentials([
                        file(credentialsId: 'ec2_aws_pub', variable: 'KEY_PATH')
                ]) {
                    dir ('stage') {
                        sh "cp ${KEY_PATH} aws_pub.key"
                        sh "export TF_VAR_ec2_key_path='aws_pub.key'; terraform apply -input=false tfplan"
                        sh "rm aws_pub.key"
                    }
                }
            }
        }
    }
}