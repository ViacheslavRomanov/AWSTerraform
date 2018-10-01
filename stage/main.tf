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
    "10.0.2.0/24"]
  vpcCIDRPublicSubnet = [
    "10.0.10.0/24",
    "10.0.20.0/24"]

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

module "sgELB" {
  source = "../modules/sg"
  sgName = "sgELB"
  sgEnvironment = "stage"
  sgRuleList = [ "http", "default_egress" ]
  sgRuleDefnition = {
    http = ["ingress", 80, 80, "tcp", true, false, false, false]
    default_egress = ["egress", 0, 0, "-1", true, false, false, false]
  }
  sgCIDRList = {
    http = ["0.0.0.0/0"]
    default_egress = ["0.0.0.0/0"]
  }
  sgVPCId = "${module.vpc.vpc_id}"
}

module "iamGenericRole" {
  source = "../modules/iam"
  iamName = "GenereicRole"
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
module "rds" {
  source = "../modules/rds"
  rdsName = "APPRDS"
  rdsIsMultiAZ = "false"
  rdsInstanceClass = "db.t2.micro"
  rdsDBName = "${var.db_name}"
  rdsDBUser = "${var.db_user}"
  rdsDBPassword = "${var.db_password}"
  rdsSubnetIdList = ["${module.vpc.vpc-privatesubnet-ids}"]
}

module "elb" {
  source = "../modules/elb"
  elbName = "appELB"
  elbEnvironment = "stage"
  elbSubnetList = ["${module.vpc.vpc-publicsubnet-ids}"]
  elbListenerList = [
    {
      instance_port     = "8181"
      instance_protocol = "HTTP"
      lb_port           = "80"
      lb_protocol       = "HTTP"
    }
  ]
  elbHealthCheckList = [
    {
      target              = "HTTP:8181/"
      interval            = 30
      healthy_threshold   = 2
      unhealthy_threshold = 2
      timeout             = 5
    }
  ]
  elbCookieSticknessLBHttpEnable = "true"
  elbCookieSticknessAppHttpEnable = "true"
  elbCrossZoneLoadBalancingEnable = "true"
  elbSGList =  [ "${module.vpc.default_security_group_id}", "${module.sgELB.security_group_id}" ]
}

data "template_file" "user_data" {
  template = "env_set.tpl"
  vars {
    dbserver = "${module.rds.db_instance_address}"
    dbname = "${var.db_name}"
    dbuser = "${var.db_user}"
    dbpass = "${var.db_password}"
  }
}

module "asg" {
  source = "../modules/asg"
  asgName = "asgAPP"
  asgIsCreate = "true"
  asgVPCSubnetList = ["${module.vpc.vpc-privatesubnet-ids}"]
  asgIsUserDataFile = "false"
  asgEC2UserData = "${data.template_file.user_data.rendered}"
  asgLBList = ["${module.elb.elb_name}"]
  asgHealthCheckType = "ELB"
  asgAMI = "${data.aws_ami.app_image.id}"
  asgEC2InstanceType = "t2.micro"
  asgSGList = ["${module.vpc.default_security_group_id}", "${module.sgAPP.security_group_id}"]
  asgIAMInstanceProfile = "${module.iamGenericRole.instance_profile_id}"
  asgMinSize = "2"
  asgMaxSize = "3"
  asgDesiredCapacity = "2"
  key_path = "${var.ec2_key_path}"
}


