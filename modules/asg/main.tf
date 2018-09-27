#---------------------------------------------------
# Create AWS ASG
#---------------------------------------------------
data "template_file" "instances_index" {
  count = "${var.asgMaxSize}"
  template = "${lower(var.asgName)}-${lower(var.asgEnvironment)}-${count.index+1}"
}

resource "aws_autoscaling_group" "asg" {
  count = "${var.asgIsCreate ? 1 : 0}"

  launch_configuration = "${var.asgIsCreateLC ? element(aws_launch_configuration.lc.*.name, 0) : var.asgLaunchConfigurationName}"
  #name                        = "${var.name}-asg-${var.environment}"
  name_prefix = "${var.asgName}-asg-"
  vpc_zone_identifier = [
    "${var.asgVPCSubnetList}"]
  max_size = "${var.asgMaxSize}"
  min_size = "${var.asgMinSize}"
  desired_capacity = "${var.asgDesiredCapacity}"

  health_check_grace_period = "${var.asgHealthCheckGracePeriod}"
  health_check_type = "${var.asgHealthCheckType}"
  load_balancers = [
    "${var.asgLBList}"]

  min_elb_capacity = "${var.asgELBMinCapacity}"
  wait_for_elb_capacity = "${var.asgIsWaitELBCapacity}"
  target_group_arns = [
    "${var.asgALBTargetGroupARNList}"]
  default_cooldown = "${var.asgCooldownDefault}"
  force_delete = "${var.asgForceDeleteEnable}"
  termination_policies = "${var.asgTerminationPolicyList}"
  suspended_processes = "${var.asgSuspendedProcessList}"
  placement_group = "${var.asgPlacementGroup}"
  enabled_metrics = [
    "${var.asgEnabledMetricList}"]
  metrics_granularity = "${var.asgMetricsGranularity}"
  wait_for_capacity_timeout = "${var.asgWaitForCapacityTimeout}"
  protect_from_scale_in = "${var.asgIsProtectFromScaleIn}"

  tags = {
    /*Name = "${data.template_file.instances_index.rendered}" */
    Environment = "${var.asgEnvironment}"
  }

  depends_on = [
    "aws_launch_configuration.lc"]
}


/*resource "aws_autoscaling_attachment" "elb_autoscaling_attachment" {
  count = "${upper(var.asgLBType) == "ELB" && length(var.asgLBList) > 0 ? 1 : 0}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  elb = "${data.template_file.elb_index.rendered}"
}
/*data "template_file" "elb_index" {
  count = "${length(var.asgLBList)}"
  template = "${var.asgLBList[count.index]}"
} */

/*resource "aws_autoscaling_attachment" "alb_autoscaling_attachment" {
  count = "${upper(var.asgLBType) == "ALB" && length(var.asgLBList) > 0 ? 1 : 0}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.id}"
  alb_target_group_arn = "${data.template_file.alb_index.rendered}"
}
data "template_file" "alb_index" {
  count = "${length(var.asgLBList)}"
  template = "${var.asgLBList[count.index]}"
} */


resource "aws_key_pair" "key_pair" {
  key_name = "${lower(var.asgName)}-key_pair-${lower(var.asgEnvironment)}"
  public_key = "${file("${var.key_path}")}"
}

resource "aws_launch_configuration" "lc" {
  count = "${var.asgIsCreateLC ? 1 : 0}"

  #name                        = "${var.name}-lc-${var.environment}"
  name_prefix = "${var.asgName}-lc-"
  image_id = "${var.asgAMI}"
  instance_type = "${var.asgEC2InstanceType}"
  security_groups = [
    "${var.asgSGList}"]
  iam_instance_profile = "${var.asgIAMInstanceProfile}"

  key_name = "${aws_key_pair.key_pair.id}"
  user_data = "${var.asgIsUserDataFile ? file("${var.asgEC2UserData}") : var.asgEC2UserData }"
  associate_public_ip_address = "${var.asgInstancePublicIPAssociationEnable}"

  enable_monitoring = "${var.asgMonitoringEnable}"

  placement_tenancy = "${var.asgPlacementTenancy}"

  ebs_optimized = "${var.asgIsEBSOptimized}"
  ebs_block_device = "${var.asgEBSBlockDeviceList}"
  ephemeral_block_device = "${var.asgEphemeralBlockDeviceList}"
  root_block_device = "${var.asgRootBlockDeviceList}"

  lifecycle {
    create_before_destroy = "true"
  }

  depends_on = [
    "aws_key_pair.key_pair"]

}

resource "aws_autoscaling_policy" "scale_up" {
  count = "${var.asgAutoscalingScheduleEnable ? 1 : 0}"

  name = "${var.asgName}-asg_policy-${var.asgEnvironment}-scale_up"
  scaling_adjustment = "${var.asgSizeScale}"
  adjustment_type = "${var.asgAdjustmentType}"
  cooldown = "${var.asgCooldownDefault}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_autoscaling_group.asg"]
}
resource "aws_autoscaling_policy" "scale_down" {
  count = "${var.asgAutoscalingScheduleEnable ? 1 : 0}"

  name = "${var.asgName}-asg_policy-${var.asgEnvironment}-scale_down"
  scaling_adjustment = "-${var.asgSizeScale}"
  adjustment_type = "${var.asgAdjustmentType}"
  cooldown = "${var.asgCooldownDefault}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"

  lifecycle {
    create_before_destroy = true
  }

  depends_on = [
    "aws_autoscaling_group.asg"]
}
resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = "${var.asgAutoscalingScheduleEnable ? 1 : 0}"

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = "${var.asgMinSize}"
  max_size = "${var.asgMaxSize}"
  desired_capacity = "${var.asgMaxSize}"
  recurrence = "${var.asgRecurrenceScaleUpCrontab}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"

  depends_on = [
    "aws_autoscaling_group.asg"]
}
resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = "${var.asgAutoscalingScheduleEnable ? 1 : 0}"

  scheduled_action_name = "scale-in-at-night"
  min_size = "${var.asgMinSize}"
  max_size = "${var.asgMaxSize}"
  desired_capacity = "${var.asgMinSize}"
  recurrence = "${var.asgRecurrenceScaleDownCrontab}"
  autoscaling_group_name = "${aws_autoscaling_group.asg.name}"

  depends_on = [
    "aws_autoscaling_group.asg"]
}

