output "cert_info" {
  value = {
    domains         = fastly_tls_subscription.subscription.domains
    created_at      = fastly_tls_subscription.subscription.created_at
    updated_at      = fastly_tls_subscription.subscription.updated_at
    tls_config_name = data.fastly_tls_configuration.configuration.name
  }
}

output "dns_info" {
  value = aws_route53_record.records
}