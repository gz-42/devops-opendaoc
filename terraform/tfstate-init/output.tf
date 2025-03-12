output "state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = module.tfstate.state_bucket_name
  sensitive  = true
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  value       = module.tfstate.dynamodb_table_name
  sensitive   = true
}