variable "vpcName" {
  default = "custom-vpc"
}

variable "ipv6AssignCIDRBlock" {
  default = false
}

variable "vpcCIDRBlock" {
  default = "10.0.0.0/16"
}

variable "instanceTenancy" {
  default = "default"
}

variable "dnsSupport" {
  default = true
}

variable "dnsHostNames" {
  default = true
}

variable "environment" {
  default     = "STAGE"
}

variable "allowed_ports" {
  description = "Allowed ports from/to host"
  type        = "list"
  default     = ["80", "443", "8080", "8443"]
}

variable "enable_all_egress_ports" {
  description = "Allows all ports from host"
  default     = false
}

variable "vpcCIDRPublicSubnet" {
  description = "CIDRs for the public subnets"
  type        = "list"
  default     = []
}

variable "vpcCIDRPrivateSubnet" {
  description = "CIDRs for the private subnets"
  type        = "list"
  default     = []
}

#variable "vpcAZ" {
#  description = "A list of AZ in the selected region"
#  type        = "list"
#  default     = []
#}
variable "vpcRegion" {
  description = "Creating VPC's region"
}

variable "vpcAZ" {
  type = "map"

  default = {
    us-east-1      = ["us-east-1a", "us-east-1b", "us-east-1c", "us-east-1d", "us-east-1e", "us-east-1f"]
    us-east-2      = ["us-east-2a", "eu-east-2b", "eu-east-2c"]
    us-west-1      = ["us-west-1a", "us-west-1c"]
    us-west-2      = ["us-west-2a", "us-west-2b", "us-west-2c"]
    ca-central-1   = ["ca-central-1a", "ca-central-1b"]
    eu-west-1      = ["eu-west-1a", "eu-west-1b", "eu-west-1c"]
    eu-west-2      = ["eu-west-2a", "eu-west-2b"]
    eu-central-1   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
    ap-south-1     = ["ap-south-1a", "ap-south-1b"]
    sa-east-1      = ["sa-east-1a", "sa-east-1c"]
    ap-northeast-1 = ["ap-northeast-1a", "ap-northeast-1c"]
    ap-southeast-1 = ["ap-southeast-1a", "ap-southeast-1b"]
    ap-southeast-2 = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
    ap-northeast-1 = ["ap-northeast-1a", "ap-northeast-1c"]
    ap-northeast-2 = ["ap-northeast-2a", "ap-northeast-2c"]
  }
}
variable "vpcMapPublicIpOnLaunch" {
  default = "false"
}

variable "vpcPublicPropagatingVGWs" {
  description = "A list of VGWs the public route table should propagate."
  type = "list"
  default     = []
}

variable "vpcPrivatePropagatingVGWs" {
  description = "A list of VGWs the private route table should propagate."
  type        = "list"
  default     = []
}

variable "vpcEnableVPNGateway" {
  description = "Should be true if you want to create a new VPN Gateway resource and attach it to the VPC"
  default     = false
}

variable "vpcEnableNATGateway" {
  description = "Allow Nat GateWay to/from private network"
  default     = "false"
}

variable "vpcSingleNATGateway" {
  description = "should be true if you want to provision a single shared NAT Gateway across all of your private networks"
  default     = "false"
}

variable "vpcEnableEIP" {
  description = "Allow creation elastic eip"
  default     = "false"
}

variable "vpcEnableDHCPOptions" {
  description = "Should be true if you want to specify a DHCP options set with a custom domain name, DNS servers, NTP servers, netbios servers, and/or netbios server type"
  default     = false
}

variable "vpcDHCPOptionsDomainName" {
  description = "Specifies DNS name for DHCP options set"
  default     = ""
}

variable "vpcDHCPOptionsDomainNameServers" {
  description = "Specify a list of DNS server addresses for DHCP options set, default to AWS provided"
  type        = "list"
  default     = ["AmazonProvidedDNS"]
}

variable "vpcDHCPOptionsNtpServers" {
  description = "Specify a list of NTP servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "vpcDHCPOptionsNetbiosNameServers" {
  description = "Specify a list of netbios servers for DHCP options set"
  type        = "list"
  default     = []
}

variable "vpcDHCPOptionsNetbiosNodeType" {
  description = "Specify netbios node_type for DHCP options set"
  default     = ""
}

