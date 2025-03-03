output "state_bucket_name" {
  description = "The name of the S3 bucket for Terraform state"
  value       = module.tfstate.state_bucket_name
}

output "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  value       = module.tfstate.dynamodb_table_name
}

output "terraform_backend_config" {
  description = "Copy this output to configure your Terraform backend"
  value = <<-EOT
    terraform {
      backend "s3" {
        bucket         = "${module.tfstate.state_bucket_name}"
        key            = "terraform.tfstate"
        region         = "${var.region}"
        dynamodb_table = "${module.tfstate.dynamodb_table_name}"
        encrypt        = true
      }
    }
  EOT
}