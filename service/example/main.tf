module "service" {
  source          = "../"
  domain          = "terratest.hkakehas.tokyo"
  papertrail_addr = "logs3.papertrailapp.com"
  papertrail_port = 43844
}

output "domain" {
  value = module.service.service_info.domain
}