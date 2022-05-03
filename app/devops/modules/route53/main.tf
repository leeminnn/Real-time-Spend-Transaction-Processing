data "aws_route53_zone" "itsag1t5_com" {
  zone_id = "Z09751501DHXQBHT2OEV3"
}

resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.itsag1t5_com.zone_id
  name    = "api.itsag1t5.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.itsag1t5_alb.dns_name
    zone_id                = data.aws_lb.itsag1t5_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "frontend_client" {
  zone_id = data.aws_route53_zone.itsag1t5_com.zone_id
  name    = "itsag1t5.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.itsag1t5_frontend_alb.dns_name
    zone_id                = data.aws_lb.itsag1t5_frontend_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "frontend_admin" {
  zone_id = data.aws_route53_zone.itsag1t5_com.zone_id
  name    = "admin.itsag1t5.com"
  type    = "A"

  alias {
    name                   = data.aws_lb.itsag1t5_frontend_admin_alb.dns_name
    zone_id                = data.aws_lb.itsag1t5_frontend_admin_alb.zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_record" "nameservers" {
  allow_overwrite = true
  name            = "itsag1t5.com"
  ttl             = 21600
  type            = "NS"
  zone_id         = data.aws_route53_zone.itsag1t5_com.zone_id

  records = [
    "ns-1483.awsdns-57.org",
    "ns-1816.awsdns-35.co.uk",
    "ns-180.awsdns-22.com",
    "ns-706.awsdns-24.net",
  ]
}


###############################################################################
# API Load Balancer
###############################################################################

data "aws_lb" "itsag1t5_alb" {
  name = "${var.environment_prefix}Alb"
}

data "aws_lb" "itsag1t5_frontend_alb" {
  name = "${var.environment_prefix}FrontendAlb"
}

data "aws_lb" "itsag1t5_frontend_admin_alb" {
  name = "${var.environment_prefix}FrontendAdminAlb"
}