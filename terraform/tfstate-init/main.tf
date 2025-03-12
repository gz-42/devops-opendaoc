provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "management"
      Project     = var.prefix
      ManagedBy   = "Terraform"
    }
  }
}

module "tfstate" {
  source = "./tfstate"
  
  state_bucket_name   = "${var.prefix}-terraform-state"
  dynamodb_table_name = "${var.prefix}-terraform-locks"
}