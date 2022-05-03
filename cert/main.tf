data "fastly_tls_configuration" "configuration" {
  name = var.tls_config
}

data "aws_route53_zone" "zone" {
  name         = var.dns_zone
  private_zone = false
}

resource "fastly_tls_subscription" "subscription" {
  domains               = [var.domain]
  configuration_id      = data.fastly_tls_configuration.configuration.id
  certificate_authority = "lets-encrypt"
  force_destroy         = true
}

resource "aws_route53_record" "domain_validation" {
  depends_on      = [fastly_tls_subscription.subscription]
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = fastly_tls_subscription.subscription.managed_dns_challenge.record_name
  type            = fastly_tls_subscription.subscription.managed_dns_challenge.record_type
  records         = [fastly_tls_subscription.subscription.managed_dns_challenge.record_value]
  ttl             = 60
}

resource "fastly_tls_subscription_validation" "validation" {
  subscription_id = fastly_tls_subscription.subscription.id
  depends_on      = [aws_route53_record.domain_validation]
}

resource "aws_route53_record" "record" {
  depends_on      = [fastly_tls_subscription_validation.validation]
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = var.domain
  type            = "CNAME"
  records         = [one([for r in data.fastly_tls_configuration.configuration.dns_records : r.record_value if r.record_type == "CNAME"])]
  ttl             = 300
}