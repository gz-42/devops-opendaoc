output "velero_bucket_name" {
  description = "Name of the S3 bucket for Velero backups"
  value       = local.bucket_name
}

output "velero_bucket_arn" {
  description = "ARN of the S3 bucket for Velero backups"
  value       = module.aws_s3_bucket.s3_bucket_arn
}

output "velero_role_arn" {
  description = "ARN of the IAM role for Velero"
  value       = aws_iam_role.devops-opendaoc_velero_role.arn
}

output "velero_namespace" {
  description = "Kubernetes namespace where Velero is deployed"
  value       = "velero"
}

output "velero_service_account" {
  description = "Kubernetes service account used by Velero"
  value       = "velero-server"
}