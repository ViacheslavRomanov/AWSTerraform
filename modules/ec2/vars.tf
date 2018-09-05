#-----------------------------------------------------------
# Global or/and default variables
#-----------------------------------------------------------
variable "ec2Name" {
  description = "Name to be used on all resources as prefix"
  default     = "TEST-EC2"
}

variable "region" {
  description = "The region where to deploy this code (e.g. us-east-1)."
  default     = "us-east-1"
}

variable "ec2Environment" {
  description = "Environment for service"
  default     = "STAGE"
}

variable "ec2AMI" {
  description = "I added only 3 regions to show the map feature but you can add all"
}

variable "ec2InstancesAmount" {
  description = "Number of instances to make"
  default     = "1"
}

variable "ec2InstanceType" {
  description = "Type of instance t2.micro, m1.xlarge, c1.medium etc"
  default     = "t2.micro"
}

variable "ec2DiskSize" {
  description = "disk size for EC2 instance"
  default     = 8
}

variable "ec2Tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host."
  default     = "default"
}

variable "ec2EBSOptimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default     = false
}

variable "ec2InstanceTerminationProtectionEnable" {
  description = "If true, enables EC2 Instance Termination Protection"
  default     = false
}

variable "ec2InstanceInitiatedShutdownBehavior" {
  description = "Shutdown behavior for the instance" # https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/terminating-instances.html#Using_ChangingInstanceInitiatedShutdownBehavior
  default     = ""
}

variable "ec2PublicKeyFile" {
  description = "Key path to your RSA|DSA key"
  default     = "./aws_key.pub"
}

variable "ec2PrivateKeyFile" {
  description = "Private key"
  default     = "~/.ssh/aws_key"
}

variable "ec2PublicIPAssociateEnable" {
  description = "Enabling associate public ip address (Associate a public ip address with an instance in a VPC)"
  default     = "true"
}

variable "ec2SourceDestCheckEnable" {
  description = " (Optional) Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs. Defaults true."
  default     = "false"
}

variable "ec2SubnetId" {
  description = "Public subnet ID"
}

variable "ec2VPCSecurityGroupIDList" {
  description = " SG for EC2"
  type        = "list"
}

variable "monitoring" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default     = false
}

variable "ec2UserDataFile" {
  description = "The user data file to provide when launching the instance"
  default     = "./user_data.sh"
}

variable "ec2IAMInstanceProfile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default     = ""
}

variable "ec2PlacementGroup" {
  description = "The Placement Group to start the instance in"
  default     = ""
}

variable "ec2PrivateIP" {
  description = "Private IP address to associate with the instance in a VPC"
  default     = ""
}

variable "ec2IPv6AddressCount" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet."
  default     = 0
}

variable "ec2IPv6AddressList" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type = list
  default     = []
}

variable "ec2VolumeTagMap" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type = map
  default     = {}
}

variable "root_block_device" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  default     = ""
}

variable "ec2EBSDeviceList" {
  description = "Additional EBS block devices to attach to the instance"
  type = list
  default     = []
}

variable "ec2EphemeralDeviceList" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type = list
  default     = []
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type = list
  default     = []
}