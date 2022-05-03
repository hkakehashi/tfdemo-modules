variable "domain" {
  type        = string
  description = "The domain that the service will respond to"
}

variable "enable_waf" {
  type        = bool
  default     = false
  description = "Provision a WAF object with pre-determine rules, OWASP config, response, and logging endpoints"
}

variable "papertrail_addr" {
  type        = string
  description = "The hostname of the logging endpoint"
}

variable "papertrail_port" {
  type        = number
  description = "The port number of the logging endpoint"
}