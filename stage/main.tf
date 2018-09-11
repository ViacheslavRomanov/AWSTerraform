##################################################################################
# PROVIDERS
##################################################################################

provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region = "us-east-1"
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

module "vpc" {
  source = "../modules/vpc"
  vpcName = "myVPC"
  allowed_ports = []
  vpcRegion = "us-east-1"
  vpcCIDRPrivateSubnet = [
    "10.0.1.0/24",
    "10.0.2.0/24",
    "10.0.3.0/24"]
  vpcCIDRPublicSubnet = [
    "10.0.4.0/24",
    "10.0.5.0/24"]

  vpcSingleNATGateway = "false"
  vpcEnableNATGateway = "false"
}

module "sgDMZ" {
  source = "../modules/sg"
  sgName = "sg0DMZ"
  sgEnvironment = "stage"
  sgRuleList = [ "ssh", "http", "openvpn", "default_egress" ]
  /*
  value ={
   "rule_name" = [type, from_port, to_port, protocol, isCIDR, isPrefix, isSGs, isSelf]
  }
*/
  sgRuleDefnition = {

    ssh = ["ingress", 22, 22, "tcp", true, false, false, false]
    http = ["ingress", 80, 80, "tcp", true, false, false, false]
    mysql = ["ingress", 3306, 3306, "tcp", true, false, false, false]
    openvpn = ["ingress", 1194, 1194, "udp", true, false, false, false]
    default_egress = ["egress", 0, 0, "-1", true, false, false, false]
  }

  sgCIDRList = {
    ssh = ["0.0.0.0/0"]
    http = ["0.0.0.0/0"]
    mysql = ["0.0.0.0/0"]
    openvpn = ["0.0.0.0/0"]
    default_egress = ["0.0.0.0/0"]
  }
  sgVPCId = "${module.vpc.vpc_id}"
}
module "iam" {
  source = "../modules/iam"
  iamName = "TEST-IAM"
  iamEnvironment = "STAGE"

  iamRolePrincipals = [
    "ec2.amazonaws.com",
  ]
  iamPolicyActions = [
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
  source                              = "../modules/ec2"
  ec2Name                                = "Bastion"
  ec2AMI = "ami-c58c1dd3"
  ec2Environment                         = "stage"
  ec2InstanceType                   = "t2.micro"
  ec2PublicIPAssociateEnable  = "true"
  ec2Tenancy                             = "${module.vpc.instance_tenancy}"
  ec2IAMInstanceProfile                = "${module.iam.instance_profile_id}"
  ec2SubnetId                           = "${element(module.vpc.vpc-publicsubnet-ids, 0)}"
  ec2VPCSecurityGroupIDList              = ["${module.sgDMZ.security_group_id}"]
  monitoring                          = "false"
  ec2PrivateKeyFile = ""
  ec2UserDataFile = "../modules/services/bastion-openvpn/bastion.sh"
  ec2PublicKeyFile = "../vars/aws_key.pub"
}

output "public_ip" {
  value = [
    "${module.bastion.public_dns}"]
}

output "copy_settings_command" {
  value = [ "scp -i PUBLIC_KEY ec2-user@$PUBLIC_IP:/etc/openvpn/easy-rsa/user_settings.tar.gz user-set.tar/gz" ]
}

