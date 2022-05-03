data "aws_route53_zone" "zone" {
  name         = "hkakehas.tokyo"
  private_zone = false
}

resource "aws_route53_record" "record" {
  allow_overwrite = true
  zone_id         = data.aws_route53_zone.zone.zone_id
  name            = "terratest.hkakehas.tokyo"
  type            = "CNAME"
  records         = ["j.sni.global.fastly.net"]
  ttl             = 300
}