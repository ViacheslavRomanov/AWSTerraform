variable "asgName" {
  description = "Name to be used on all resources as prefix"
  default = "TEST-ASG"
}

variable "asgEnvironment" {
  description = "Environment for service"
  default = "STAGE"
}


variable "asgIsCreateLC" {
  description = "Whether to create launch configuration"
  default = true
}

variable "asgIsCreate" {
  description = "Whether to create autoscaling group"
  default = true
}

variable "asgLBType" {
  description = "Type of load balancer. Ex: ELB, ALB etc"
  default = "elb"
}

# Launch configuration
variable "asgLaunchConfigurationName" {
  description = "The name of the launch configuration to use (if it is created outside of this module)"
  default = ""
}

variable "asgEC2InstanceType" {
  description = "Type of instance t2.micro, m1.xlarge, c1.medium etc"
  default = "t2.micro"
}

variable "asgIAMInstanceProfile" {
  description = "The IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile."
  default = ""
}

variable "key_path" {
  description = "Key path to your RSA|DSA key"
}

variable "asgSGList" {
  description = "A list of security group IDs to assign to the launch configuration"
  type = "list"
}

variable "asgInstancePublicIPAssociationEnable" {
  description = "Enabling associate public ip address (Associate a public ip address with an instance in a VPC)"
  default = false
}

variable "asgIsUserDataFile" {
  default = "false"
}

variable "asgEC2UserData" {
  description = "The user data file to provide when launching the instance"
  default = ""
}

variable "asgMonitoringEnable" {
  description = "If true, the launched EC2 instance will have detailed monitoring enabled"
  default = false
}

variable "asgIsEBSOptimized" {
  description = "If true, the launched EC2 instance will be EBS-optimized"
  default = false
}

variable "asgRootBlockDeviceList" {
  description = "Customize details about the root block device of the instance. See Block Devices below for details"
  type = "list"
  default = []
}

variable "asgEBSBlockDeviceList" {
  description = "Additional EBS block devices to attach to the instance"
  type = "list"
  default = []
}

variable "asgEphemeralBlockDeviceList" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type = "list"
  default = []
}


variable "asgPlacementTenancy" {
  description = "The tenancy of the instance. Valid values are 'default' or 'dedicated'"
  default = "default"
}

variable "asgAMI" {
}

#variable "asgCreateBeforeDestroyEnable" {
#    description = "Create before destroy"
#    default     = "true"
#}


variable "asgMaxSize" {
  description = "Max size of instances to making autoscaling"
  default = "1"
}

variable "asgSizeScale" {
  description = "Size of instances to making autoscaling(up/down)"
  default = "1"
}

variable "asgMinSize" {
  description = "Min size of instances to making autoscaling"
  default = "1"
}

variable "asgAdjustmentType" {
  description = "Specifies whether the adjustment is an absolute number or a percentage of the current capacity. Valid values are ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity."
  default = "ChangeInCapacity"
}

variable "asgRecurrenceScaleUpCrontab" {
  description = " Cronjob time for scale-up"
  default = "0 9 * * *"
}

variable "asgRecurrenceScaleDownCrontab" {
  description = " Cronjob time for scale-down"
  default = "0 20 * * *"
}

variable "asgAutoscalingScheduleEnable" {
  description = "Enabling autoscaling schedule"
  default = false
}

variable "asgDesiredCapacity" {
  description = "Desired numbers of servers in ASG"
  default = 1
}

variable "asgVPCSubnetList" {
  description = "A list of subnet IDs to launch resources in"
  type = "list"
}

variable "asgCooldownDefault" {
  description = "The amount of time, in seconds, after a scaling activity completes before another scaling activity can start"
  default = 300
}

variable "asgHealthCheckGracePeriod" {
  description = "Time (in seconds) after instance comes into service before checking health."
  default = 300
}

variable "asgHealthCheckType" {
  description = "Controls how health checking is done. Need to choose 'EC2' or 'ELB'"
  default = "EC2"
}

variable "asgForceDeleteEnable" {
  description = "Allows deleting the autoscaling group without waiting for all instances in the pool to terminate."
  default = "true"
}

variable "asgLBList" {
  description = "A list of elastic load balancer names to add to the autoscaling group names"
  type = "list"
  default = []
}

variable "asgALBTargetGroupARNList" {
  description = "A list of aws_alb_target_group ARNs, for use with Application Load Balancing"
  type = "list"
  default = []
}

variable "asgTerminationPolicyList" {
  description = "A list of policies to decide how the instances in the auto scale group should be terminated. The allowed values are OldestInstance, NewestInstance, OldestLaunchConfiguration, ClosestToNextInstanceHour, Default"
  type = "list"
  default = [
    "Default"]
}

variable "asgSuspendedProcessList" {
  description = "A list of processes to suspend for the AutoScaling Group. The allowed values are Launch, Terminate, HealthCheck, ReplaceUnhealthy, AZRebalance, AlarmNotification, ScheduledActions, AddToLoadBalancer. Note that if you suspend either the Launch or Terminate process types, it can prevent your autoscaling group from functioning properly."
  type = "list"
  default = []
}

variable "asgPlacementGroup" {
  description = "The name of the placement group into which you'll launch your instances, if any"
  default = ""
}

variable "asgMetricsGranularity" {
  description = "The granularity to associate with the metrics to collect. The only valid value is 1Minute"
  default = "1Minute"
}

variable "asgEnabledMetricList" {
  description = "A list of metrics to collect. The allowed values are GroupMinSize, GroupMaxSize, GroupDesiredCapacity, GroupInServiceInstances, GroupPendingInstances, GroupStandbyInstances, GroupTerminatingInstances, GroupTotalInstances"
  type = "list"

  default = [
    "GroupMinSize",
    "GroupMaxSize",
    "GroupDesiredCapacity",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupTerminatingInstances",
    "GroupTotalInstances",
  ]
}

variable "asgWaitForCapacityTimeout" {
  description = "A maximum duration that Terraform should wait for ASG instances to be healthy before timing out. (See also Waiting for Capacity below.) Setting this to '0' causes Terraform to skip all Capacity Waiting behavior."
  default = "10m"
}

variable "asgELBMinCapacity" {
  description = "Setting this causes Terraform to wait for this number of instances to show up healthy in the ELB only on creation. Updates will not wait on ELB instance number changes"
  default = 0
}

variable "asgIsWaitELBCapacity" {
  description = "Setting this will cause Terraform to wait for exactly this number of healthy instances in all attached load balancers on both create and update operations. Takes precedence over min_elb_capacity behavior."
  default = false
}

variable "asgIsProtectFromScaleIn" {
  description = "Allows setting instance protection. The autoscaling group will not select instances with this setting for terminination during scale in events."
  default = false
}
