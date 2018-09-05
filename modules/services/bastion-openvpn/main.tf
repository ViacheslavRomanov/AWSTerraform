resource "aws_key_pair" "key_pair" {
  key_name = "${var.ec2BastionKeyName}-key_pair-${var.ec2BastionEnvironment}"
  public_key = "${file("${var.ec2BastionKeyPath}")}"
}

resource "aws_security_group" "openvpn" {
  name = "${var.ec2BastionName}-sg-openvpn"
  vpc_id = "${var.vpcId}"
  description = "OpenVPN security group"

  tags {
    Name = "${var.ec2BastionName}-sg-openvpn"
  }

  ingress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "${var.vpcCIDR}"]
  }

  # For OpenVPN Client Web Server & Admin Web UI & SSH
  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 443
    to_port = 443
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    protocol = "udp"
    from_port = 1194
    to_port = 1194
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  egress {
    protocol = -1
    from_port = 0
    to_port = 0
    cidr_blocks = [
      "0.0.0.0/0"]
  }
}

resource "aws_instance" "ec2-bastion-instance" {
  count = "${var.ec2BastionHACreate ? 0 : 1}"
  instance_type = "${var.ec2BastionType}"
  ami = "${var.ec2BastionAMI}"
  associate_public_ip_address = true
  subnet_id = "${var.ec2BastionSubnetId}"
  key_name = "${aws_key_pair.key_pair.id}"
  vpc_security_group_ids = ["${aws_security_group.openvpn.id}"]
  monitoring = false
  iam_instance_profile        = "${var.ec2IAMInstanceProfile}"

  lifecycle {
    create_before_destroy = true
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = ["private_ip", "vpc_security_group_ids", "root_block_device"]
  }
  tags {
    Name            = "${var.ec2BastionName}-${var.ec2BastionEnvironment}"
    Environment     = "${var.ec2BastionEnvironment}"
  }

}

resource "aws_launch_configuration" "ec2-bastion-lc" {
  count = "${var.ec2BastionHACreate ? 1 : 0}"
  image_id = "${var.ec2BastionAMI}"
  instance_type = "${var.ec2BastionType}"
  enable_monitoring = false
  vpc_security_group_ids = ["${aws_security_group.openvpn.id}"]

  lifecycle {
    create_before_destroy = true
  }
}