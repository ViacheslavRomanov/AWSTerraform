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

provider "aws" {
  ## ADD ENV VAR AWS_ACCESS_KEY_ID  AWS_SECRET_ACCESS_KEY
  #  access_key = "${var.aws_access_key}"
  #  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

data "aws_ami" "app_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["JENKINS_BUILD_SERVER*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"]
}

module "sgJBS" {
  source = "../modules/sg"
  sgName = "sgJenkins"
  sgEnvironment = "prod"
  sgRuleList = [ "ssh", "jenkins", "default_egress" ]
  sgRuleDefnition = {
    ssh = ["ingress", 22, 22, "tcp", true, false, false, false]
    jenkins = ["ingress", 8080, 8080, "tcp", true, false, false, false]
    default_egress = ["egress", 0, 0, "-1", true, false, false, false]
  }
  sgCIDRList = {
    ssh = ["0.0.0.0/0"]
    jenkins = ["0.0.0.0/0"]
    default_egress = ["0.0.0.0/0"]
  }
  sgVPCId = "${aws_default_vpc.default.id}"
}

variable "jenkins_pub_key" {}

resource "aws_key_pair" "key_pair" {
  key_name = "build_server_keypair"
  public_key = "${file("${var.jenkins_pub_key}")}"
}

resource "aws_instance" "jenkins" {

  ami = "${data.aws_ami.app_image.id}"
  instance_type = "t2.micro"
  security_groups = [ "${module.sgJBS.security_group_name}" ]
  key_name = "${aws_key_pair.key_pair.id}"
  monitoring = "false"
  tags
  {
    Name = "Jenkins build server"
  }
  depends_on = [
    "aws_key_pair.key_pair"]

}

resource "aws_eip" "server_ip" {
  vpc = "true"
  instance = "${aws_instance.jenkins.id}"
}

resource "null_resource" "null0"{
  provisioner "local-exec" {
    command = <<EOT
    echo 'export JENKINS_SERVER_IP=${aws_instance.jenkins.public_ip}'>my_env
    EOT
  }
}

output "jenkins_server_ip" {
  value = "${aws_instance.jenkins.public_ip}"
}