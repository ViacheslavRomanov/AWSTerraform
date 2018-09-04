###############################
# Define vpc
###############################
resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpcCIDRBlock}"
  instance_tenancy     = "${var.instanceTenancy}"
  enable_dns_support   = "${var.dnsSupport}"
  enable_dns_hostnames = "${var.dnsHostNames}"
  assign_generated_ipv6_cidr_block = "${var.ipv6AssignCIDRBlock}"
  tags {
    Name = "${var.vpcName}"
  }
}
###############################
#Security group
###############################
resource "aws_security_group" "sg" {
  name                = "${var.vpcName}-sg"
  description         = "Security Group ${var.vpcName}-sg-${var.environment}"
  vpc_id              = "${aws_vpc.vpc.id}"

  tags {
    Name            = "${var.vpcName}-sg-${var.environment}"
    Environment     = "${var.environment}"
  }
  lifecycle {
    create_before_destroy = true
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  depends_on  = ["aws_vpc.vpc"]
}

resource "aws_security_group_rule" "ingress_ports" {
  count               = "${length(var.allowed_ports)}"

  type                = "ingress"
  security_group_id   = "${aws_security_group.sg.id}"
  from_port           = "${element(var.allowed_ports, count.index)}"
  to_port             = "${element(var.allowed_ports, count.index)}"
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]

  depends_on          = ["aws_security_group.sg"]
}
resource "aws_security_group_rule" "egress_ports" {
  count               = "${var.enable_all_egress_ports ? 0 : length(var.allowed_ports)}"

  type                = "egress"
  security_group_id   = "${aws_security_group.sg.id}"
  from_port           = "${element(var.allowed_ports, count.index)}"
  to_port             = "${element(var.allowed_ports, count.index)}"
  protocol            = "tcp"
  cidr_blocks         = ["0.0.0.0/0"]
  depends_on          = ["aws_security_group.sg"]
}
resource "aws_security_group_rule" "icmp-self" {
  security_group_id   = "${aws_security_group.sg.id}"
  type                = "ingress"
  protocol            = "icmp"
  from_port           = -1
  to_port             = -1
  self                = true
  depends_on          = ["aws_security_group.sg"]
}

resource "aws_security_group_rule" "default_egress" {
  count             = "${var.enable_all_egress_ports ? 1 : 0}"

  type              = "egress"
  security_group_id = "${aws_security_group.sg.id}"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  depends_on        = ["aws_security_group.sg"]
}
###############################
#Create some random shuffle AZ
###############################
resource "random_shuffle" "random_az"{
  input = "${var.vpcAZ[var.vpcRegion]}"
  result_count = 1
}
###############################
#Create private subnet(-s)
###############################
resource "aws_subnet" "private_subnets" {
  count                   = "${length(var.vpcCIDRPrivateSubnet)}"
  cidr_block              = "${element(var.vpcCIDRPrivateSubnet, count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "false"
  availability_zone       = "${element(random_shuffle.random_az.result,0)}"
  tags {
    #Name            = "private_subnet-${element(aws_subnet.private_subnets.*.availability_zone,0)}"
    Environment     = "${var.environment}"
  }

  depends_on        = ["aws_vpc.vpc"]
}
###############################
#Create public subnet(-s)
###############################
resource "aws_subnet" "public_subnets" {
  count                   = "${length(var.vpcCIDRPublicSubnet)}"
  cidr_block              = "${element(var.vpcCIDRPublicSubnet, count.index)}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  map_public_ip_on_launch = "${var.vpcMapPublicIpOnLaunch}"
  availability_zone       = "${element(random_shuffle.random_az.result,0)}"
  tags {
    #Name            = "public_subnet-${random_shuffle.random_az.result}"
    Environment     = "${var.environment}"
  }
  depends_on        = ["aws_vpc.vpc"]
}
###############################
#Create IGW
###############################
resource "aws_internet_gateway" "vpc_igw" {
  count =   "${length(var.vpcCIDRPublicSubnet) > 0 ? 1 : 0}"
  vpc_id = "${aws_vpc.vpc.id}"
  tags {
    Name            = "vpc_igw ${var.vpcName}-vpc-${var.environment}"
    Environment     = "${var.environment}"
  }
  depends_on        = ["aws_vpc.vpc"]
}
resource "aws_route_table" "public_route_tables" {
  count            = "${length(var.vpcCIDRPublicSubnet) > 0 ? 1 : 0}"
  vpc_id           = "${aws_vpc.vpc.id}"
  propagating_vgws = ["${var.vpcPublicPropagatingVGWs}"]
  tags {
    Name            = "public_route_tables"
    Environment     = "${var.environment}"
  }
  depends_on        = ["aws_vpc.vpc"]
}

resource "aws_route" "public_internet_gateway" {
  count                  = "${length(var.vpcCIDRPublicSubnet) > 0 ? 1 : 0}"
  route_table_id         = "${aws_route_table.public_route_tables.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.vpc_igw.id}"
  depends_on             = ["aws_internet_gateway.vpc_igw", "aws_route_table.public_route_tables"]
}

###############################
# Create EIP
###############################
resource "aws_eip" "nat_eip" {
  count       = "${var.vpcEnableNATGateway ? (var.vpcSingleNATGateway ? 1 : length(var.vpcAZ[var.vpcRegion])) : 0}"
  vpc         = true
  depends_on  = ["aws_internet_gateway.vpc_igw"]
}
###############################
# Create NAT-GW
###############################
resource "aws_nat_gateway" "nat_gw" {
  count       = "${var.vpcEnableNATGateway ? (var.vpcSingleNATGateway ? 1 : length(var.vpcAZ[var.vpcRegion])) : 0}"
  allocation_id   = "${element(aws_eip.nat_eip.*.id, (var.vpcSingleNATGateway ? 0 : count.index))}"
  subnet_id       = "${element(aws_subnet.public_subnets.*.id, (var.vpcSingleNATGateway ? 0 : count.index))}"
  depends_on      = ["aws_internet_gateway.vpc_igw", "aws_subnet.public_subnets"]
}
###############################
# Create private route table
###############################
resource "aws_route_table" "private_route_tables" {
  count               = "${length(var.vpcAZ[var.vpcRegion])}"
  vpc_id              = "${aws_vpc.vpc.id}"
  propagating_vgws    = ["${var.vpcPrivatePropagatingVGWs}"]
  tags {
    Name            = "private_route_tables"
    Environment     = "${var.environment}"
  }
  depends_on          = ["aws_vpc.vpc"]
}

resource "aws_route" "private_nat_gateway" {
  count                   = "${var.vpcEnableNATGateway ? length(var.vpcAZ[var.vpcRegion]) : 0}"
  route_table_id          = "${element(aws_route_table.private_route_tables.*.id, count.index)}"
  destination_cidr_block  = "0.0.0.0/0"
  nat_gateway_id          = "${element(aws_nat_gateway.nat_gw.*.id, count.index)}"
  depends_on              = ["aws_nat_gateway.nat_gw", "aws_route_table.private_route_tables"]
}

###############################
# Create VPN Gateway
###############################
resource "aws_vpn_gateway" "vpn_gw" {
  count   = "${var.vpcEnableVPNGateway ? 1 : 0}"
  vpc_id  = "${aws_vpc.vpc.id}"
  tags {
    Name            = "vpn_gateway"
    Environment     = "${var.environment}"
  }
  depends_on          = ["aws_vpc.vpc"]
}
###############################
# Create DHCP
###############################
resource "aws_vpc_dhcp_options" "vpc_dhcp_options" {
  count                = "${var.vpcEnableDHCPOptions ? 1 : 0}"

  domain_name          = "${var.vpcDHCPOptionsDomainName}"
  domain_name_servers  = "${var.vpcDHCPOptionsDomainNameServers}"
  ntp_servers          = "${var.vpcDHCPOptionsNtpServers}"
  netbios_name_servers = "${var.vpcDHCPOptionsNetbiosNameServers}"
  netbios_node_type    = "${var.vpcDHCPOptionsNetbiosNodeType}"

  tags {
    Name            = "dhcp"
    Environment     = "${var.environment}"
  }
}
##############################
# Route Table Associations
##############################
##############################
# ...private
##############################
resource "aws_route_table_association" "private_route_table_associations" {
  count           = "${length(var.vpcCIDRPrivateSubnet)}"
  subnet_id       = "${element(aws_subnet.private_subnets.*.id, count.index)}"
  route_table_id  = "${element(aws_route_table.private_route_tables.*.id, count.index)}"
  depends_on      = ["aws_route_table.private_route_tables", "aws_subnet.private_subnets"]
}
##############################
# ...public
##############################
resource "aws_route_table_association" "public_route_table_associations" {
  count           = "${length(var.vpcCIDRPublicSubnet)}"
  subnet_id       = "${element(aws_subnet.public_subnets.*.id, count.index)}"
  route_table_id  = "${aws_route_table.public_route_tables.id}"
  depends_on      = ["aws_route_table.public_route_tables", "aws_subnet.public_subnets"]
}
###############################
# DHCP Options Set Association
###############################
resource "aws_vpc_dhcp_options_association" "vpc_dhcp_options_association" {
  count           = "${var.vpcEnableDHCPOptions ? 1 : 0}"
  vpc_id          = "${aws_vpc.vpc.id}"
  dhcp_options_id = "${aws_vpc_dhcp_options.vpc_dhcp_options.id}"
  depends_on      = ["aws_vpc.vpc", "aws_vpc_dhcp_options.vpc_dhcp_options"]
}