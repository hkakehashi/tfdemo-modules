variable "dns_zone" {
  type        = string
  description = "Name of the hosted zone"
}

variable "domains" {
  type        = set(string)
  description = "The set of domains to enable TLS"
}

variable "tls_config" {
  type        = string
  description = "TLS configuration to be enabled on the domains"
  default     = "TLS v1.3"

  validation {
    condition     = contains(["TLS v1.2", "TLS v1.3", "TLS v1.3+0RTT", "HTTP/3 & TLS v1.3", "HTTP/3 & TLS v1.3 + 0RTT"], var.tls_config)
    error_message = "Valid values for var.tls_config are: [\"TLS v1.2\", \"TLS v1.3\", \"TLS v1.3+0RTT\", \"HTTP/3 & TLS v1.3\", \"HTTP/3 & TLS v1.3 + 0RTT\"]."
  }
}