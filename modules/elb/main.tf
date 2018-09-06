resource "aws_elb" "elb" {
  name = "${lower(var.elbName)}-elb-${lower(var.elbEnvironment)}"
  # can be use availability_zones or subnets....
  #availability_zones  = ["${split(",", (lookup(var.availability_zones, var.region)))}"] #["us-east-1a", "us-east-1b"]
  subnets = [
    "${var.elbSubnetList}"]
  security_groups = [
    "${var.elbSGList}"]
  internal = "${var.elbIsInternal}"

  cross_zone_load_balancing = "${var.elbCrossZoneLoadBalancingEnable}"
  idle_timeout = "${var.elbIdleTimeout}"
  connection_draining = "${var.elbIsConnectionDraining}"
  connection_draining_timeout = "${var.elbConnectionDrainingTimeout}"

  access_logs = [
    "${var.elbAccessLogList}"]
  listener = [
    "${var.elbListenerList}"]
  health_check = [
    "${var.elbHealthCheckList}"]

  tags {
    Name = "${lower(var.elbName)}-elb-${lower(var.elbEnvironment)}"
    Environment = "${var.elbEnvironment}"
  }
}

resource "aws_elb_attachment" "elb_attachment" {
  count = "${length(var.elbInstanceList)}"

  elb = "${aws_elb.elb.name}"
  instance = "${element(var.elbInstanceList, count.index)}"

  depends_on = [
    "aws_elb.elb"]
}

resource "aws_lb_cookie_stickiness_policy" "lb_cookie_stickiness_policy_http" {
  count = "${var.elbCookieSticknessLBHttpEnable ? 1 : 0}"

  name = "${lower(var.elbName)}-lb-cookie-stickiness-policy-http-${lower(var.elbEnvironment)}"
  load_balancer = "${aws_elb.elb.id}"
  lb_port = "${var.elbHttpPort}"
  cookie_expiration_period = "${var.elbCookieExpPeriod}"

  depends_on = [
    "aws_elb.elb"]
}
resource "aws_lb_cookie_stickiness_policy" "lb_cookie_stickiness_policy_https" {
  count = "${var.elbCookieSticknessLBHttpEnable ? 0 : 1}"

  name = "${lower(var.elbName)}-lb_cookie-stickiness-policy-https-${lower(var.elbEnvironment)}"
  load_balancer = "${aws_elb.elb.id}"
  lb_port = "${var.elbHttpsPort}"
  cookie_expiration_period = "${var.elbCookieExpPeriod}"

  depends_on = [
    "aws_elb.elb"]
}

resource "aws_app_cookie_stickiness_policy" "app_cookie_stickiness_policy_http" {
  count = "${var.elbCookieSticknessAppHttpEnable ? 1 : 0}"

  name = "${lower(var.elbName)}-app-cookie-stickiness-policy-http-${lower(var.elbEnvironment)}"
  load_balancer = "${aws_elb.elb.id}"
  lb_port = "${var.elbHttpPort}"
  cookie_name = "${var.elbCookieName}"

  depends_on = [
    "aws_elb.elb"]
}
resource "aws_app_cookie_stickiness_policy" "app_cookie_stickiness_policy_https" {
  count = "${var.elbCookieSticknessAppHttpEnable ? 0 : 1}"

  name = "${lower(var.elbName)}-app-cookie-stickiness-policy-https-${lower(var.elbEnvironment)}"
  load_balancer = "${aws_elb.elb.id}"
  lb_port = "${var.elbHttpsPort}"
  cookie_name = "${var.elbCookieName}"

  depends_on = [
    "aws_elb.elb"]
}
