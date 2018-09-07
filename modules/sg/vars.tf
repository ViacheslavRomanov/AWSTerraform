variable "sgName" {
  description = "(Optional, Forces new resource) The name of the security group. If omitted, Terraform will assign a random, unique name"
  default = "UNDEF-SG-NAME"
}

variable "sgEnvironment" {
  description = "Environment for service"
  default = "UNDEV-SG-ENV"
}

variable "sgNamePrefix" {
  description = "(Optional, Forces new resource) Creates a unique name beginning with the specified prefix. Conflicts with name"
  default = ""
}

variable "sgDescription" {
  description = "(Optional, Forces new resource) The security group description. Defaults to <Managed by Terraform>. Cannot be blank. NOTE: This field maps to the AWS GroupDescription attribute, for which there is no Update API. If you'd like to classify your security groups in a way that can be updated, use tags."
  default = ""
}

variable "sgVPCId" {
  description = "(Optional, Forces new resource) The VPC ID."
}

variable "sgRuleList" {
  description = "Rule list"
  type = "list"
}

variable "sgRuleDefnition" {
  description = "Map of rules definitions"
  type = "map"
  /*
    value ={
     "rule_name" = [type, from_port, to_port, protocol, isCIDR, isPrefix, isSGs, isSelf]
    }
  */
  default = {
    ssh = ["ingress", 22, 22, "tcp", true, false, false, false]
  }
}

/*
  value = {
   rule1 = ["0.0.0.0/0"]
  }
*/
variable "sgPrefixList" {
  type = "map"
  default = {
    ssh = ["ngw-12345678"]
  }
}

variable "sgCIDRList" {
  type = "map"
  default = {
    ssh = ["0.0.0.0/0"]
  }
}

variable "sgSourceSGList" {
  type = "map"
  default = {
    ssh = ["sg-12345678"]
  }

}

