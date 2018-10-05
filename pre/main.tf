##################################################################################
# REMOTE STATE
##################################################################################
terraform {
  backend "s3" {
    encrypt = true
    bucket = "aws-state-keeper"
    dynamodb_table = "jenkins-lock-keeper"
    region = "us-east-1"
    key = "terraform/jenkins.tfstate"
  }
}

variable "aws_region" {}
variable "jenkins_public_keyfile" {}
variable "jenkins_private_keyfile" {}

provider "aws" {
  ## ADD ENV VAR AWS_ACCESS_KEY_ID  AWS_SECRET_ACCESS_KEY
  #  access_key = "${var.aws_access_key}"
  #  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

module "jbs" {
  source = "../modules/jenkins"
  jenkinsPublicKeyPath = "${var.jenkins_public_keyfile}"
  jenkinsPrivateKeyPath = "${var.jenkins_private_keyfile}"
}

resource "null_resource" "null0"{
  provisioner "local-exec" {
    command = <<EOT
    echo 'export JENKINS_SERVER_IP=${module.jbs.jenkins_server_ip}'>my_env
    EOT
  }
}

