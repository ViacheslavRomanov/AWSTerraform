resource "aws_default_vpc" "default" {
  tags {
    Name = "Default VPC"
  }
}

data "aws_ami" "app_image" {
  most_recent = true
  filter {
    name   = "name"
    values = ["JENKINS_BUILD_SERVER*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["self"]
}

module "sgJBS" {
  source = "../sg"
  sgName = "sgJenkins"
  sgEnvironment = "prod"
  sgRuleList = [ "ssh", "jenkins", "default_egress" ]
  sgRuleDefnition = {
    ssh = ["ingress", 22, 22, "tcp", true, false, false, false]
    jenkins = ["ingress", 8080, 8080, "tcp", true, false, false, false]
    default_egress = ["egress", 0, 0, "-1", true, false, false, false]
  }
  sgCIDRList = {
    ssh = ["0.0.0.0/0"]
    jenkins = ["0.0.0.0/0"]
    default_egress = ["0.0.0.0/0"]
  }
  sgVPCId = "${aws_default_vpc.default.id}"
}

resource "aws_key_pair" "key_pair" {
  key_name = "build_server_keypair"
  public_key = "${file("${var.jenkinsPublicKeyPath}")}"
}

data "template_file" "setup_jenkins" {
  template = "${file("${path.module}/config.tpl")}"

  vars = {
    jnlp_port = "${var.jenkinsJnlpPort}"
    plugins = "${join(" ", var.jenkinsPluginList)}"
  }
}

resource "aws_instance" "jenkins" {

  ami = "${data.aws_ami.app_image.id}"
  instance_type = "t2.micro"
  security_groups = [ "${module.sgJBS.security_group_name}" ]
  key_name = "${aws_key_pair.key_pair.id}"
  monitoring = "false"
  #user_data = "${data.template_file.setup_jenkins.rendered}" # unable to control a full setup event
  provisioner "file" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.jenkinsPrivateKeyPath)}"
    }
    content     = "${data.template_file.setup_jenkins.rendered}"
    destination = "/tmp/setup.sh"
  }

  provisioner "remote-exec" {
    connection  = {
      user = "ec2-user"
      private_key = "${file(var.jenkinsPrivateKeyPath)}"
    }
    inline = [
      "chmod +x /tmp/setup.sh",
      "sudo dos2unix /tmp/setup.sh",
      "sudo /tmp/setup.sh"
    ]
  }
  tags
  {
    Name = "Jenkins build server"
  }
  depends_on = [
    "aws_key_pair.key_pair"]

}

resource "aws_eip" "server_ip" {
  vpc = "true"
  instance = "${aws_instance.jenkins.id}"
}

resource "null_resource" "null0"{
  provisioner "local-exec" {
    command = <<EOT
    echo 'export JENKINS_SERVER_IP=${aws_instance.jenkins.public_ip}'>my_env
    EOT
  }
}
