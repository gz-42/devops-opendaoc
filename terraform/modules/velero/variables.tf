variable "region" {
  description = "AWS region"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name"
  type        = string
  sensitive   = true
}
variable "backup_namespace" {
  description = "namespace for the Velero backup"
  type        = string
  default     = "velero"
}

variable "velero_provider" {
  description = "Cloud provider for Velero"
  type        = string
  default     = "aws"
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  sensitive   = true
}

variable "bucket_name" {
  description = "Base name of the S3 bucket for Velero backups"
  type        = string
  sensitive   = true
}

variable "namespace_to_backup" {
  description = "Name of the namespace to backup"
  type        = string
  default     = "prod"
}

variable "backup_schedule" {
  description = "Cron schedule for Velero backups"
  type        = string
  default     = "0 1 * * *"  # Daily at 1 AM
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
  sensitive   = true
}