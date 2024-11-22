variable "subject" {
  description = "The subject of the certificate"
  type = object({
    common_name         = string
    organization        = optional(string)
    organizational_unit = optional(string)
  })
}

variable "dns_names" {
  description = "A list of DNS names to include in the certificate"
  type        = list(string)
}

variable "validity_period_days" {
  description = "The number of days the certificate is valid for"
  type        = number
  default     = 365
}

variable "secret_namespace" {
  description = "The namespace to create the secret in"
  type        = string
}

variable "secret_name" {
  description = "The name of the secret"
  type        = string
  default     = "tls-secret"
}
