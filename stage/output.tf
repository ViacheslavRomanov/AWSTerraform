##################################################################################
# OUTPUT
##################################################################################

output "vpcId" {
  value = "${module.vpc.vpc_id}"
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
