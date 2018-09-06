variable "elbName" {
  description = "Name to be used on all resources as prefix"
  default = "TEST-ELB"
}

variable "elbEnvironment" {
  description = "Environment for service"
  default = "STAGE"
}

variable "elbSGList" {
  description = "A list of security group IDs to assign to the ELB. Only valid if creating an ELB within a VPC"
  type = "list"
  default = []
}

variable "elbSubnetList" {
  description = "A list of subnet IDs to attach to the ELB"
  type = "list"
  default = []
}

variable "elbInstanceList" {
  description = " Instances IDs to add them to ELB"
  type = "list"
  default = []
}

variable "elbIsInternal" {
  description = "If true, ELB will be an internal ELB"
  default = false
}

variable "elbCrossZoneLoadBalancingEnable" {
  description = "Enable cross-zone load balancing. Default: true"
  default = true
}

variable "elbIdleTimeout" {
  description = "The time in seconds that the connection is allowed to be idle. Default: 60"
  default = "60"
}

variable "elbIsConnectionDraining" {
  description = "Boolean to enable connection draining. Default: false"
  default = false
}

variable "elbConnectionDrainingTimeout" {
  description = "The time in seconds to allow for connections to drain. Default: 300"
  default = 300
}

variable "elbAccessLogList" {
  description = "An access logs block. Uploads access logs to S3 bucket"
  type = "list"
  default = []
}

variable "elbListenerList" {
  description = "A list of Listener block"
  type = "list"
}

variable "elbHealthCheckList" {
  description = " Health check"
  type = "list"
}

variable "elbCookieSticknessLBHttpEnable" {
  description = "Enable lb cookie stickiness policy http. If set true, will add it, else will use https"
  default = "true"
}

variable "elbCookieSticknessAppHttpEnable" {
  description = "Enable app cookie stickiness policy http. If set true, will add it, else will use https"
  default = "true"
}

variable "elbHttpPort" {
  description = "Set http lb port for lb_cookie_stickiness_policy_http|app_cookie_stickiness_policy_http policies"
  default = "80"
}

variable "elbHttpsPort" {
  description = "Set https lb port for lb_cookie_stickiness_policy_http|app_cookie_stickiness_policy_http policies"
  default = "443"
}

variable "elbCookieExpPeriod" {
  description = "Set cookie expiration period"
  default = 600
}

variable "elbCookieName" {
  description = "Set cookie name"
  default = "SessionID"
}
