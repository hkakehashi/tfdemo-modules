// Terraform resources that the test depends on
resource "fastly_service_vcl" "service" {
  name = "Test service for Terratest"

  dynamic "domain" {
    for_each = local.domains

    content {
      name = domain.value
    }
  }

  backend {
    name              = "httpbin"
    address           = "httpbin.org"
    port              = 443
    use_ssl           = true
    ssl_cert_hostname = "httpbin.org"
    ssl_sni_hostname  = "httpbin.org"
  }

  force_destroy = true
}