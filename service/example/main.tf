module "service" {
  source          = "../"
  domain          = var.domain
  papertrail_addr = var.papertrail_addr
  papertrail_port = var.papertrail_port
  enable_acl      = var.enable_acl
  allowed_ips     = var.allowed_ips
}

output "domain" {
  value = module.service.service_info.domain
}