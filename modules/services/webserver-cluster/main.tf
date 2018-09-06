##################################################################################
# RESOURCES
##################################################################################
resource "aws_security_group" "bastion-sg" {
  name = "${var.cluster_name}-bastion-sg"

  ingress {
    protocol = "tcp"
    from_port = 22
    to_port = 22
    cidr_blocks = [
      "0.0.0.0/0"]
  }

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
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

resource "aws_security_group" "elb-sg" {
  name = "${var.cluster_name}-elb-sg"

  ingress {
    protocol = "tcp"
    from_port = 80
    to_port = 80
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

data "template_file" "user_data" {
  template = "${file("${path.module}/user_data.sh")}"
}

resource "aws_launch_configuration" "web_lc" {
  image_id = "${var.ec2AMI}"
  instance_type = "${var.ec2Type}"
  security_groups = [
    "${aws_security_group.bastion-sg.name}"]
  enable_monitoring = false
  name = "${var.cluster_name}-lc"

  user_data = "${data.template_file.user_data.rendered}"

  lifecycle {
    create_before_destroy = true
  }
}

data "aws_availability_zones" "all" {}

resource "aws_elb" "elb" {
  name = "${var.cluster_name}-elb"
  availability_zones = [
    "${data.aws_availability_zones.all.names}"]
  security_groups = [
    "${aws_security_group.elb-sg.id}"]

  "listener" {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }
  health_check {
    healthy_threshold = 2
    interval = 30
    target = "HTTP:80/"
    timeout = 3
    unhealthy_threshold = 2
  }
}

resource "aws_autoscaling_group" "asg-web" {
  launch_configuration = "${aws_launch_configuration.web_lc.id}"
  availability_zones = [
    "${data.aws_availability_zones.all.names}"]
  load_balancers = [
    "${aws_elb.elb.name}"]
  health_check_type = "ELB"

  max_size = "${var.asgMaxSize}"
  min_size = "${var.asgMinSize}"

  tag {
    key = "Name"
    value = "${var.cluster_name}"
    propagate_at_launch = true
  }
}

