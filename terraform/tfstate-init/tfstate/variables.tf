variable "state_bucket_name" {
  description = "The name of the S3 bucket to store Terraform state"
  type        = string
  sensitive   = true
}

variable "dynamodb_table_name" {
  description = "The name of the DynamoDB table for Terraform state locking"
  type        = string
  sensitive   = true
  default     = "terraform.tfstate"
#  default     = "{{ secret.TF_STATE_KEY }}"
}

