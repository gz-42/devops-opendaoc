variable "prometheus_namespace" {
  type        = string
  default     = "monitoring"
}

variable "profile" {
  type        = string
}

variable "root_domain_name" {
  type        = string
}
variable "grafana_host" {
  description = "Hostname for grafana (will be utilised in ingress if enabled)"
  type        = string
  default     = "grafana-devops-opendaoc.gz-42.com"
}

variable "grafana_pwd" {
  type        = string
  sensitive   = true
}

variable "grafana_ingress_class" {
  description = "Ingress class to use for grafana"
  type        = string
  default     = "nginx"
}

variable "grafana_ingress_enabled" {
  description = "Enable/disable grafana ingress"
  type        = bool
  default     = true
}

variable "grafana_ingress_tls_acme_enabled" {
  description = "Enable/disable acme TLS for ingress"
  type        = bool
  default     = false
}

variable "grafana_ingress_ssl_passthrough_enabled" {
  description = "Enable/disable SSL passthrough for ingresss"
  type        = bool
  default     = true
}

variable "certificate_secret_name" {
  type        = string
  description = "Name of the certificate secret"
}

variable "namespace" {
  type        = string
  description = "Namespace for the imported certificate"
  default     = "monitoring"
}

variable "certificate_namespace" {
  type        = string
  description = "Namespace where the original certificate is stored"
  default     = "certmanager"
}