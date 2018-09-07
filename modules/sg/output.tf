output "security_group_id" {
  value = "${aws_security_group.sg.id}"
}

output "security_group_rules" {
  value = [
    "${aws_security_group_rule.rule.*.id}"]
}