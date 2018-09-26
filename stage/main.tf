##################################################################################
# REMOTE STATE
##################################################################################
terraform {
  backend "s3" {
    encrypt = true
    bucket = "aws-state-keeper"
    dynamodb_table = "aws-lock-keeper"
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
##################################################################################
# MODULES
##################################################################################


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
  vpcMapPublicIpOnLaunch = "false"
}

data "aws_ami" "app_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["APP_PROD_AMI*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"]
}

module "sgAPP" {
  source = "../modules/sg"
  sgName = "sgAPP"
  sgEnvironment = "stage"
  sgRuleList = [ "ssh", "app", "default_egress" ]
  sgRuleDefnition = {
    ssh = ["ingress", 22, 22, "tcp", true, false, false, false]
    app = ["ingress", 8181, 8181, "tcp", true, false, false, false]
    default_egress = ["egress", 0, 0, "-1", true, false, false, false]
  }
  sgCIDRList = {
    ssh = ["0.0.0.0/0"]
    app = ["0.0.0.0/0"]
    default_egress = ["0.0.0.0/0"]
  }
  sgVPCId = "${module.vpc.vpc_id}"
}

module "iamGenericRole" {
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


//
//module "bastion" {
//  source                              = "../modules/ec2"
//  ec2Name                                = "Bastion"
//  ec2AMI = "ami-c58c1dd3"
//  ec2Environment                         = "stage"
//  ec2InstanceType                   = "t2.micro"
//  ec2PublicIPAssociateEnable  = "true"
//  ec2Tenancy                             = "${module.vpc.instance_tenancy}"
//  ec2IAMInstanceProfile                = "${module.iam.instance_profile_id}"
//  ec2SubnetId                           = "${element(module.vpc.vpc-publicsubnet-ids, 0)}"
//  ec2VPCSecurityGroupIDList              = ["${module.sgDMZ.security_group_id}"]
//  monitoring                          = "false"
//  ec2PrivateKeyFile = ""
//  ec2UserDataFile = "../modules/services/bastion-openvpn/bastion.sh"
//  ec2PublicKeyFile = "../vars/aws_key.pub"
//}
//
//output "public_ip" {
//  value = [
//    "${module.bastion.public_dns}"]
//}
//
//output "copy_settings_command" {
//  value = [ "scp -i PUBLIC_KEY ec2-user@$PUBLIC_IP:/etc/openvpn/easy-rsa/user_settings.tar.gz user-set.tar/gz" ]
//}
/*module "rds" {
  source = "../modules/rds"

  rdsSubnetIdList = ["${module.vpc.vpc-privatesubnet-ids}"]
} */
