resource "fastly_service_vcl" "service" {
  force_destroy = true
  name          = var.domain

  domain {
    name = var.domain
  }

  backend {
    name              = "httpbin"
    address           = "httpbin.org"
    port              = 443
    use_ssl           = true
    ssl_cert_hostname = "httpbin.org"
    ssl_sni_hostname  = "httpbin.org"
  }

  vcl {
    name    = "main"
    content = file("${path.module}/vcl/main.vcl")
    main    = true
  }

  # Custom 404
  snippet {
    content  = file("${path.module}/vcl/snippet_fetch_custom_404.vcl")
    name     = "fetch_custom_404"
    type     = "fetch"
    priority = 100
  }

  snippet {
    content = templatefile("${path.module}/vcl/snippet_error_custom_404.vcl",
    { html = file("${path.module}/html/custom_404.html") })
    name     = "error_custom_404"
    type     = "error"
    priority = 100
  }

  // Conditionally add ACL
  dynamic "snippet" {
    for_each = var.enable_acl ? [1] : []

    content {
      content  = file("${path.module}/vcl/snippet_recv_acl.vcl")
      name     = "recv_acl"
      type     = "recv"
      priority = 90
    }
  }

  dynamic "acl" {
    for_each = var.enable_acl ? [1] : []

    content {
      name          = "allow_list"
      force_destroy = true
    }
  }

  // Conditionally add Papertrail logging endpoint
  dynamic "logging_papertrail" {
    for_each = var.papertrail_addr != "" && var.papertrail_port != 0 ? [1] : []

    content {
      name           = "accesslog"
      address        = var.papertrail_addr
      port           = var.papertrail_port
      format         = file("${path.module}/log_format/format.json")
      format_version = "2"
    }
  }
}

# ACL entries
resource "fastly_service_acl_entries" "entries" {
  count = length(var.allowed_ips) != 0 ? 1 : 0

  service_id     = fastly_service_vcl.service.id
  acl_id         = one(fastly_service_vcl.service.acl).acl_id
  manage_entries = true

  dynamic "entry" {
    for_each = var.allowed_ips

    content {
      ip      = entry.value.ip
      subnet  = entry.value.subnet
      comment = entry.value.comment
      negated = false
    }
  }
}