resource "fastly_service_vcl" "service" {
  name = "Test service for Terratest"

  domain {
    name = "terratest.hkakehas.tokyo"
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
