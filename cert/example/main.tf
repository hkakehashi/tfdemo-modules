locals {
  domains    = ["terratest-prod1.hrmsk66.com", "terratest-stage1.hrmsk66.com"]
  dns_zone   = "hrmsk66.com"
  tls_config = "HTTP/3 & TLS v1.3"
}

module "cert" {
  depends_on = [fastly_service_vcl.service]
  source     = "../"
  domains    = local.domains
  dns_zone   = local.dns_zone
  tls_config = local.tls_config
}

output "domains" {
  value = module.cert.cert_info.domains
}
