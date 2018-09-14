pipeline {
    agent any
    environment {
        TF_VAR_aws_access_key     = credentials('jenkins_aws_access_key')
        TF_VAR_aws_secret_key = credentials('jenkins_aws_secret_key')
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
                    sh 'terraform plan -input=false'
                }
            }
        }
    }
}