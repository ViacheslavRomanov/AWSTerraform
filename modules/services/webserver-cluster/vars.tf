##################################################################################
# VARIABLES
##################################################################################
variable "ec2AMI" {
  description = "AMI id for EC2 instances"
  default = "ami-c58c1dd3"
}

variable "ec2Type" {
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

variable "cluster_name" {
  description = "The name to use as a preifx for resources"
}

variable "vpcId" {
  description = "VPC ID"
}
