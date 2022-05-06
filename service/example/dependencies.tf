// Terraform resources that the test depends on
data "aws_route53_zone" "zone" {
  name         = var.dns_zone
  private_zone = false
}

resource "aws_route53_record" "record" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = var.domain
  type            = "CNAME"
  records         = ["j.sni.global.fastly.net"]
  ttl             = 300
}