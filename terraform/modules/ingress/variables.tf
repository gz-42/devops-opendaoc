variable "profile" {
  type = string
}

variable "namespace" {
  type = string
}

variable "certificate_secret_name" {
  description = "Name of the TLS secret containing the certificate"
  type        = string
}

variable "certificate_namespace" {
  description = "Namespace where the certificate secret is stored"
  type        = string
}
