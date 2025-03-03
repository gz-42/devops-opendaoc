provider "aws" {
  region = var.region
  default_tags {
    tags = {
      Environment = "management"
      Project     = var.namespace
      ManagedBy   = "Terraform"
    }
  }
}

module "tfstate" {
  source = "./tfstate"
  
  state_bucket_name   = "${var.namespace}-terraform-state"
  dynamodb_table_name = "${var.namespace}-terraform-locks"
}