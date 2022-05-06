variable "dns_zone" {
  type        = string
  description = "Name of the hosted zone"
}

variable "domain" {
  type        = string
  description = "The domain that the service will respond to"
}

variable "papertrail_addr" {
  type        = string
  description = "The hostname of the logging endpoint"
  default     = ""
}

variable "papertrail_port" {
  type        = number
  description = "The port number of the logging endpoint"
  default     = 0
}

variable "enable_acl" {
  type        = bool
  description = "Restrict IPs allowed to access the Fastly service"
  default     = false
}

variable "allowed_ips" {
  type = set(object({
    ip      = string
    subnet  = number
    comment = string
  }))
  description = "Set of IP addresses allowed to access the Fastly service"
  default     = []
}