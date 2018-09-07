resource "aws_security_group" "sg" {
  vpc_id = "${var.sgVPCId}"
  name = "${lower(var.sgName)}-sg-${lower(var.sgEnvironment)}"
  description = "${var.sgDescription == "" ? "My ${lower(var.sgName)}-sg-${lower(var.sgEnvironment)}" : var.sgDescription }"

  lifecycle {
    create_before_destroy = true
  }
  tags {
    Name = "${lower(var.sgName)}-sg-${lower(var.sgEnvironment)}-${count.index+1}"
    Environment = "${var.sgEnvironment}"
  }
}


locals {
  empty_list = []
}

resource "aws_security_group_rule" "rule" {
  count = "${length(var.sgRuleList)}"
  security_group_id = "${aws_security_group.sg.id}"

  type = "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],0)}"
  from_port = "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],1)}"
  to_port = "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],2)}"
  protocol = "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],3)}"
  cidr_blocks =  "${var.sgCIDRList[element(var.sgRuleList, count.index)]}"
  /** wait for 0.12
  /*cidr_blocks =  "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],4) ? var.sgCIDRList[element(var.sgRuleList, count.index)]  : 123 }"
  prefix_list_ids = [ "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],5)} ? ${var.sgPrefixList[element(var.sgRuleList, count.index)]}  : [] " ]
  source_security_group_id = [ "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],6)} ? ${var.sgCIDRList[element(var.sgRuleList, count.index)]}  : [] " ]

  self = [ "${element(var.sgRuleDefnition[element(var.sgRuleList, count.index)],7)} ? true  : false " ] */

  depends_on = [
    "aws_security_group.sg"]
}
