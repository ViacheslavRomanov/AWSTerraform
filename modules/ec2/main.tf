#---------------------------------------------------
# Define SSH key pair for our instances
#---------------------------------------------------
resource "aws_key_pair" "key_pair" {
  key_name = "${lower(var.ec2Name)}-key_pair-${lower(var.ec2Environment)}"
  public_key = "${file("${var.ec2PublicKeyFile}")}"
}
#---------------------------------------------------
# Create AWS Instance
#---------------------------------------------------
resource "aws_instance" "instance" {
  count = "${var.ec2InstancesAmount}"

  ami = "${var.ec2AMI}"
  instance_type = "${var.ec2InstanceType}"
  user_data = "${file("${var.ec2UserDataFile}")}"
  key_name = "${aws_key_pair.key_pair.id}"
  subnet_id = "${var.ec2SubnetId}"
  vpc_security_group_ids = [
    "${var.ec2VPCSecurityGroupIDList}"]
  monitoring = "${var.monitoring}"
  iam_instance_profile = "${var.ec2IAMInstanceProfile}"

  # Note: network_interface can't be specified together with associate_public_ip_address
  #network_interface           = "${var.network_interface}"
  associate_public_ip_address = "${var.ec2PublicIPAssociateEnable}"
  private_ip = "${var.ec2PrivateIP}"
  ipv6_address_count = "${var.ec2IPv6AddressCount}"
  ipv6_addresses = "${var.ec2IPv6AddressList}"

  source_dest_check = "${var.ec2SourceDestCheckEnable}"
  disable_api_termination = "${var.ec2InstanceTerminationProtectionEnable}"
  instance_initiated_shutdown_behavior = "${var.ec2InstanceInitiatedShutdownBehavior}"
  placement_group = "${var.ec2PlacementGroup}"
  tenancy = "${var.ec2Tenancy}"

  ebs_optimized = "${var.ec2EBSOptimized}"
  volume_tags = "${var.ec2VolumeTagMap}"
  root_block_device {
    volume_size = "${var.ec2DiskSize}"
    #    volume_type = "gp2"
  }
  ebs_block_device = "${var.ec2EBSDeviceList}"
  ephemeral_block_device = "${var.ec2EphemeralDeviceList}"

  lifecycle {
    create_before_destroy = true
    # Due to several known issues in Terraform AWS provider related to arguments of aws_instance:
    # (eg, https://github.com/terraform-providers/terraform-provider-aws/issues/2036)
    # we have to ignore changes in the following arguments
    ignore_changes = [
      "private_ip",
      "vpc_security_group_ids",
      "root_block_device"]
  }

  tags {
    Name = "${lower(var.ec2Name)}-ec2-${lower(var.ec2Environment)}-${count.index+1}"
    Environment = "${var.ec2Environment}"
  }
  ##############################################
  # Provisioning
  #############################################
  /*provisioner "remote-exec" {
    inline = [
      "sudo yum update -y",
      "sudo yum upgrade -y",
      "uname -a"
    ]
    connection {
      #host        = "${element(aws_instance.instance.*.public_ip, 0)}"
      user        = "ec2-user"
      #password   = ""
      timeout     = "5m"
      private_key = "${file("${var.ec2PrivateKeyFile}")}"
      agent       = "true"
      type        = "ssh"
    }
  }*/

  depends_on = [
    "aws_key_pair.key_pair"]
}