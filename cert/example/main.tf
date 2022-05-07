locals {
  domains    = ["terratest-prod1.hkakehas.tokyo", "terratest-stage1.hkakehas.tokyo"]
  dns_zone   = "hkakehas.tokyo"
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
