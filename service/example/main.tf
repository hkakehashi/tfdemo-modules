module "service" {
  source          = "../"
  domain          = "terratest.hkakehas.tokyo"
  papertrail_addr = "xxx.papertrailapp.com"
  papertrail_port = 12345
}

output "domain" {
  value = module.service.service_info.domain
}