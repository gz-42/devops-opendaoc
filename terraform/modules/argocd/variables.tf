variable "devops_opendaoc_repo" {
  type        = string
}

variable "profile" {
  type        = string
}

variable "argocd_hostname" {
  description = "Hostname for ArgoCD"
  type        = string
  sensitive   = true
}

variable "argocd_ingress_class" {
  description = "Ingress class to use for argocd"
  type        = string
  default     = "nginx"
}

variable "argocd_ingress_enabled" {
  description = "Enable/disable argocd ingress"
  type        = bool
  default     = true
}

variable "argocd_ingress_tls_acme_enabled" {
  description = "Enable/disable acme TLS for ingress"
  type        = string
  default     = "false"
}

variable "argocd_ingress_force_ssl_redirect_enabled" {
  description = "Enable/disable force SSL redirect for ingresss"
  type        = string
  default     = "true"
}

variable "argocd_ingress_ssl_passthrough_enabled" {
  description = "Enable/disable SSL passthrough for ingresss"
  type        = string
  default     = "true"
}

variable "mariadb_root_password" {
  description = "Root password for mariadb"
  type        = string
  sensitive   = true
}

variable "db_connection_string" {
  description = "Connection string for opendaoc-core"
  type        = string
  sensitive   = true
}