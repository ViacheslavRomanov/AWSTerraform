#Actual resources
##################################################################################
# REMOTE STATE
##################################################################################
data "terraform_remote_state" "core" {
  backend = "s3"
  config {
    encrypt = true
    bucket = "aws-state-keeper"
    region = "us-east-1"
    key = "terraform/state.tfstate"
  }
}
##################################################################################
# PROVIDERS
##################################################################################
provider "aws" {
  ## ADD ENV VAR AWS_ACCESS_KEY_ID  AWS_SECRET_ACCESS_KEY
  #  access_key = "${var.aws_access_key}"
  #  secret_key = "${var.aws_secret_key}"
  region = "${var.aws_region}"
}

output "vpc_id" {
  value = "${data.terraform_remote_state.core.vpcId}"
}