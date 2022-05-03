output "cert_info" {
  value = {
    domain          = one(fastly_tls_subscription.subscription.domains)
    created_at      = fastly_tls_subscription.subscription.created_at
    updated_at      = fastly_tls_subscription.subscription.updated_at
    tls_config_name = data.fastly_tls_configuration.configuration.name
  }
}

output "dns_info" {
  value = {
    name   = aws_route53_record.record.name
    type   = aws_route53_record.record.type
    record = one(aws_route53_record.record.records)
    ttl    = aws_route53_record.record.ttl
  }
}