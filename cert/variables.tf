variable "dns_zone" {
  type        = string
  description = "Name of the hosted zone"
}

variable "domain" {
  type        = string
  description = "The domain that the service will respond to"
}

variable "tls_config" {
  type        = string
  description = "TLS configuration to be enabled on the domain"
  default     = "TLS v1.3"

  validation {
    condition     = contains(["TLS v1.3", "TLS v1.3+0RTT"], var.tls_config)
    error_message = "Valid values for var.tls_config are \"TLS v1.3\" and \"TLS v1.3+0RTT\"."
  }
}