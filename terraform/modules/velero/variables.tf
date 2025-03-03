variable "bucket_name" {
  description = "Base name of the S3 bucket for Velero backups"
  type        = string
  default     = ""
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  default     = ""
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = ""
}

variable "cluster_oidc_issuer_url" {
  description = "The URL on the EKS cluster for the OpenID Connect identity provider"
  type        = string
  default     = ""
}

variable "velero_provider" {
  description = "Cloud provider for Velero"
  type        = string
  default     = "aws"
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30
}

variable "backup_schedule" {
  description = "Cron schedule for automatic backups"
  type        = string
  default     = "0 1 * * *"  # Daily at 1 AM
}