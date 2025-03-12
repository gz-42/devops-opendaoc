variable "email" {
  type      = string
  sensitive = true
}

variable "profile" {
  type = string
}

variable "cert_manager_namespace" {
  type    = string
  default = "cert-manager"
}