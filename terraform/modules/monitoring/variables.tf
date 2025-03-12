variable "monitoring_namespace" {
  type        = string
  default     = "monitoring"
}

variable "profile" {
  type        = string
  sensitive   = true
}

variable "slack_webhook" {
  type        = string
  sensitive   = true
}

variable "slack_channel" {
  type        = string
  sensitive   = true
}

variable "grafana_hostname" {
  description = "Hostname for Grafana"
  type        = string
  sensitive   = true
}

variable "grafana_pwd" {
  type        = string
  sensitive   = true
}

variable "grafana_ingress_enabled" {
  description = "Enable/disable grafana ingress"
  type        = bool
  default     = true
}

variable "grafana_ingress_tls_acme_enabled" {
  description = "Enable/disable acme TLS for ingress"
  type        = string
  default     = "true"
}

variable "grafana_ingress_ssl_passthrough_enabled" {
  description = "Enable/disable SSL passthrough for ingresss"
  type        = string
  default     = "true"
}

variable "grafana_ingress_class" {
  description = "Ingress class to use for grafana"
  type        = string
  default     = "nginx"
}

variable "grafana_ingress_tls_secret" {
  description = "Secret name for grafana TLS cert"
  type        = string
  sensitive   = true
}
