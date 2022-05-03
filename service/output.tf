output "service_info" {
  value = {
    id             = fastly_service_vcl.service.id
    domain         = one(fastly_service_vcl.service.domain).name
    active_version = fastly_service_vcl.service.active_version
  }
}