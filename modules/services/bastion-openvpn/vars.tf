variable "ec2BastionHACreate" {
  description = "create HA Bastion configuration"
  default = false
}

variable "ec2BastionAMI" {
  description = "AMI id for EC2 instances"
  default = "ami-c58c1dd3"
}

variable "ec2BastionType" {
  description = "The type of EC2 Instances to run"
  default = "t2.micro"
}

variable "asgMinSize" {
  description = "The minimum number of EC2 instances in AutoScaling Group"
  default = 2
}

variable "asgMaxSize" {
  description = "The maximum number of EC2 instances in AutoScaling Group"
  default = 4
}

variable "vpcId" {
  description = "VPC ID"
}

variable "ec2BastionSubnetId" {
  description = "Subnet for bastion-host"
}

variable "ec2BastionKeyName" {
  default = "UNDEF_KEY"
}

variable "ec2BastionEnvironment" {
  default = "UNDEF_ENV"
}

variable "ec2BastionKeyPath" {}

variable "ec2BastionName" {
  default = "BASTION"
}

variable "vpcCIDR" {
  default = "10.0.0.0/16"
}

variable "ec2IAMInstanceProfile" {}