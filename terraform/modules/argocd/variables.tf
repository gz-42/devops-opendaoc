variable "devops_opendaoc_repo" {
  type        = string
}

variable "profile" {
  type        = string
}

variable "argocd_server_host" {
  description = "Hostname for argocd (will be utilised in ingress if enabled)"
  type        = string
  default     = "argocd-devops-opendaoc.gz-42.com"
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
  type        = bool
  default     = false
}

variable "argocd_ingress_ssl_passthrough_enabled" {
  description = "Enable/disable SSL passthrough for ingresss"
  type        = bool
  default     = true
}

variable "argocd_admin_password" {
  description = "Initial admin password for ArgoCD"
  type        = string
  sensitive   = true
}

variable "certificate_secret_name" {
  type        = string
  description = "Name of the certificate secret"
}

variable "namespace" {
  type        = string
  description = "Namespace for the imported certificate"
  default     = "argocd"
}

variable "certificate_namespace" {
  type        = string
  description = "Namespace where the original certificate is stored"
  default     = "certmanager"
}