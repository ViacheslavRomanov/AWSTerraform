##################################################################################
# OUTPUT
##################################################################################

output "aws_instance_public_dns" {
  value = "${aws_elb.elb.dns_name}"
}