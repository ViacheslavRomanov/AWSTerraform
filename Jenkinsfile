pipeline {
    agent any
    environment {
        AWS_ACCESS_KEY_ID = credentials('jenkins_aws_access_key')
        AWS_SECRET_ACCESS_KEY = credentials('jenkins_aws_secret_key')
        TF_VAR_aws_region = "${AWS_REGION}"
    }
    stages {
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
                dir ('stage') {
                    sh 'terraform plan -input=false -out=tfplan'
                }
            }
        }
        stage('Apply') {
            steps {
                dir ('stage') {
                    sh 'terraform apply -input=false tfplan'
                }
            }
        }
        stage('Create base image') {
            steps {
                build job: 'create_base_image', parameters: [
                        string(name: 'AWS_REGION', value: "${AWS_REGION}")
                ]
            }
        }
    }
}