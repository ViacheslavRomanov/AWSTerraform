output "jenkins_server_ip" {
  value = "${aws_eip.server_ip.public_ip}"
}