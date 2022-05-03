module "cert" {
  depends_on = [fastly_service_vcl.service]
  source     = "../"
  domain     = "terratest.hkakehas.tokyo"
  dns_zone   = "hkakehas.tokyo"
}

output "domain" {
  value = module.cert.cert_info.domain
}