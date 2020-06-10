resource "aws_route53_record" "wp" {
  zone_id = "${data.aws_route53_zone.domain.zone_id}"
  name    = "${local.setting["route53_hostname"]}"
  type    = "A"

  alias {
    name                   = "${module.wp.lb["dnsname"]}"
    zone_id                = "${module.wp.lb["zone_id"]}"
    evaluate_target_health = true
  }
}
