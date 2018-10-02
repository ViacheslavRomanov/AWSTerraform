##################################################################################
# OUTPUT
##################################################################################

output "vpcId" {
  value = "${module.vpc.vpc_id}"
}

output "appRegion" {
  value = "${var.aws_region}"
}

output "privateSubnetIdList" {
  value = "${module.vpc.vpc-privatesubnet-ids}"
}

output "privateSubnet0Id" {
  value = "${module.vpc.vpc-privatesubnet-id_0}"
}

output "publicSubnetIdList" {
  value = "${module.vpc.vpc-publicsubnet-ids}"
}

output "publicSubnet0Id" {
  value = "${module.vpc.vpc-publicsubnet-id_0}"
}

output "elbDNSName" {
  value = "${module.elb.elb_dns_name}"
}

output "rdsAddress" {
  value = "${module.rds.rds_addresses}"
}

output "rdsDBName" {
  value = "${module.rds.db_instance_dbname}"
}

output "rdsDBUser" {
  value = "${module.rds.db_instance_dbuser}"
}

output "rdsDBPassword" {
  value = "${module.rds.db_instance_dbpassword}"
}

output "configDBApp" {
  value = "${data.template_file.user_data.rendered}"
}