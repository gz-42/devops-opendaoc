resource "random_string" "velero_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  bucket_name = "${var.bucket_name}-${random_string.velero_bucket_suffix.result}"
  openid_connect_provider_uri = replace(var.cluster_oidc_issuer_url, "https://", "")
}

# S3 bucket for Velero backups
module "aws_s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  bucket        = local.bucket_name
  acl           = "private"
  force_destroy = true

  control_object_ownership = true
  object_ownership         = "ObjectWriter"

  attach_policy = false
  attach_deny_insecure_transport_policy = false

  versioning = {
    enabled = true
  }

  tags = {
    Name = "Velero backup bucket for ${var.cluster_name}"
  }
}

# Deploy Velero using the Helm chart
module "velero" {
  source  = "terraform-module/velero/kubernetes"
  version = "1.2.1"

  namespace_deploy            = true
  app_deploy                  = true
  cluster_name                = var.cluster_name
  openid_connect_provider_uri = local.openid_connect_provider_uri
  bucket                      = local.bucket_name

  values = [
    templatefile("${path.module}/template/values.yaml", {
      bucket_name     = local.bucket_name
      velero_provider = var.velero_provider
      region          = var.region
      role_arn        = aws_iam_role.devops-opendaoc_velero_role.arn
    })
  ]
}