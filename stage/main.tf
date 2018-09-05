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
  vpcCIDRPrivateSubnet = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  vpcCIDRPublicSubnet = ["10.0.4.0/24", "10.0.5.0/24"]

  vpcSingleNATGateway = "false"
  vpcEnableNATGateway = "false"
}

module "iam" {
  source                          = "../modules/iam"
  iamName                            = "TEST-IAM"
  iamEnvironment                     = "STAGE"

  iamRolePrincipals         = [
    "ec2.amazonaws.com",
  ]
  iamPolicyActions           = [
    "cloudwatch:GetMetricStatistics",
    "logs:DescribeLogStreams",
    "logs:GetLogEvents",
    "elasticache:Describe*",
    "rds:Describe*",
    "rds:ListTagsForResource",
    "ec2:DescribeAccountAttributes",
    "ec2:DescribeAvailabilityZones",
    "ec2:DescribeSecurityGroups",
    "ec2:DescribeVpcs",
    "ec2:Owner",
  ]
}

module "bastion" {
  source = "../modules/services/bastion-openvpn"
  ec2BastionKeyPath = "../vars/aws_key.pub"
  ec2BastionSubnetId = "${module.myVpc.vpc-publicsubnet-id_0}"
  vpcCIDR = "${module.myVpc.vpc_cidr_block}"
  vpcId = "${module.myVpc.vpc_id}"
  ec2IAMInstanceProfile = "${module.iam.instance_profile_id}"
  ec2BastionKeyName = "TESTKEY"
  ec2BastionName = "TEST"
  ec2BastionEnvironment = "STAGE"
}