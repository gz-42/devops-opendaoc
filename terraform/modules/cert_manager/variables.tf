variable "profile" {
  type = string
}

variable "cluster_name" {
  type = string
}

variable "cert_manager_namespace" {
  type        = string
  default     = "certmanager"
}

variable "certificate_bucket" {
  type = string
}

variable "certificate_secret_name" {
  description = "Name of the Kubernetes secret that will store the certificate"
  type        = string
  default     = "imported-certificate-tls"
}

variable "certificate_dns_names" {
  description = "List of DNS names covered by the certificate"
  type        = list(string)
  default     = ["*.gz-42.com"]
}

variable "certificate_target_namespaces" {
  description = "List of namespaces to copy the certificate secret to"
  type        = list(string)
  default     = ["argocd", "monitoring"]
}