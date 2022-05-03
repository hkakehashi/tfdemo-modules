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

  # WAF settings
  dynamic "condition" {
    for_each = var.enable_waf ? [1] : []

    content {
      name      = "WAF_Prefetch"
      priority  = 10
      statement = "req.backend.is_origin && !req.http.rqpass"
      type      = "PREFETCH"
    }
  }

  dynamic "condition" {
    for_each = var.enable_waf ? [1] : []

    content {
      name      = "waf-soc-logging"
      priority  = 10
      statement = "waf.executed"
      type      = "RESPONSE"
    }
  }

  dynamic "condition" {
    for_each = var.enable_waf ? [1] : []

    content {
      name      = "false"
      priority  = 10
      statement = "!req.url"
      type      = "REQUEST"
    }
  }

  dynamic "response_object" {
    for_each = var.enable_waf ? [1] : []

    content {
      name              = "WAF_Response"
      response          = "Forbidden"
      status            = "403"
      content           = "{ \"Access Denied\" : \"\"} req.http.fastly-soc-x-request-id {\"\" }"
      content_type      = "application/json"
      request_condition = "false"
    }
  }

  dynamic "waf" {
    for_each = var.enable_waf ? [1] : []

    content {
      prefetch_condition = "WAF_Prefetch"
      response_object    = "WAF_Response"
    }
  }

  dynamic "snippet" {
    for_each = var.enable_waf ? [1] : []

    content {
      name     = "Fastly_WAF_Snippet"
      type     = "recv"
      priority = 10
      content  = file("${path.module}/vcl/snippet_Fastly_WAF_Snippet.vcl")
    }
  }

  dynamic "snippet" {
    for_each = var.enable_waf ? [1] : []

    content {
      name     = "fastly_csi_init"
      type     = "recv"
      priority = 5
      content  = file("${path.module}/vcl/snippet_fastly_csi_init.vcl")
    }
  }

  dynamic "logging_papertrail" {
    for_each = var.enable_waf ? [1] : []

    content {
      name               = "weblogs"
      address            = var.papertrail_addr
      port               = var.papertrail_port
      format             = file("${path.module}/log_format/weblogs.json")
      format_version     = "2"
      response_condition = "waf-soc-logging"
    }
  }

  dynamic "logging_papertrail" {
    for_each = var.enable_waf ? [1] : []

    content {
      name           = "waflogs"
      address        = var.papertrail_addr
      port           = var.papertrail_port
      format         = file("${path.module}/log_format/waflogs.json")
      format_version = "2"
      placement      = "waf_debug"
    }
  }
}

# WAF resource settings
data "fastly_waf_rules" "default" {
  tags                    = ["owasp", "application-multi"]
  exclude_modsec_rule_ids = [4112031, 4112011, 4112012]
}

variable "type_status" {
  type = map(string)
  default = {
    score     = "score"
    threshold = "log"
    strict    = "log"
  }
}

resource "fastly_service_waf_configuration" "waf" {
  count = var.enable_waf ? 1 : 0

  waf_id                           = fastly_service_vcl.service.waf[0].waf_id
  http_violation_score_threshold   = 5
  inbound_anomaly_score_threshold  = 15
  lfi_score_threshold              = 5
  php_injection_score_threshold    = 5
  rce_score_threshold              = 5
  rfi_score_threshold              = 5
  session_fixation_score_threshold = 5
  sql_injection_score_threshold    = 15
  xss_score_threshold              = 15
  allowed_request_content_type     = "application/x-www-form-urlencoded|multipart/form-data|text/xml|application/xml|application/x-amf|application/json|text/plain"
  arg_name_length                  = 800
  arg_length                       = 2000
  paranoia_level                   = 3

  dynamic "rule" {
    for_each = data.fastly_waf_rules.default.rules
    content {
      modsec_rule_id = rule.value.modsec_rule_id
      status         = lookup(var.type_status, rule.value.type, "log")
    }
  }
}