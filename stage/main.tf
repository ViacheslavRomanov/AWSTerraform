##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "us-east-1"
}

resource "aws_default_vpc" "default" {}
##################################################################################
# MODULES
##################################################################################

/*module "webserver_cluster" {
  source = "../modules/services/webserver-cluster"
  cluster_name = "webservers-stage"
  vpcId = "${aws_default_vpc.default.id}"
} */

module "myVpc" {
  source = "../modules/vpc"
  vpcName = "myVPC"
  allowed_ports = []
  vpcRegion = "us-east-1"
  vpcCIDRPrivateSubnet = ["10.0.1.0/24", "10.0.2.0/24"]
  vpcCIDRPublicSubnet = ["10.0.3.0/24", "10.0.4.0/24"]

  vpcSingleNATGateway = "true"
  vpcEnableNATGateway = "true"
}

