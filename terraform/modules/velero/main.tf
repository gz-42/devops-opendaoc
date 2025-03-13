resource "random_string" "velero_bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

locals {
  bucket_name = "${var.bucket_name}-${random_string.velero_bucket_suffix.result}"
  openid_connect_provider_uri = replace(var.cluster_oidc_issuer_url, "https://", "")
}

module "aws_s3_bucket" {
  source        = "terraform-aws-modules/s3-bucket/aws"
  version       = "4.6.0"
  
  bucket                                = local.bucket_name
  acl                                   = "private"
  force_destroy                         = true
  control_object_ownership              = true
  object_ownership                      = "ObjectWriter"
  attach_policy                         = false
  attach_deny_insecure_transport_policy = false
  versioning                            = {enabled = true}
  tags = {
    Name = "Velero backup bucket for ${var.cluster_name}"
  }
}

resource "helm_release" "velero" {
  name              = "velero"
  repository        = "https://vmware-tanzu.github.io/helm-charts/"
  chart             = "velero"
  namespace         = "${var.backup_namespace}"
  create_namespace  = true
  version           = "8.5.0"
  timeout           = 900

  values = [
    templatefile("${path.module}/template/values.yaml", {
      bucket_name                         = local.bucket_name
      provider                            = var.velero_provider
      region                              = var.region
      role_arn                            = aws_iam_role.velero_role.arn
      namespace_to_backup                 = var.namespace_to_backup
      backup_schedule                     = var.backup_schedule     
    })
  ]
}

resource "null_resource" "velero_cleanup" {
  depends_on = [helm_release.velero]

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
      kubectl delete schedules --all -n velero
      kubectl delete backups --all -n velero
      kubectl delete restores --all -n velero
      kubectl delete backupstoragelocations --all -n velero
      kubectl delete volumesnapshotlocations --all -n velero
      kubectl delete deployments.app velero -n velero
      kubectl delete service velero -n velero
      kubectl delete jobs.batch velero-cleanup-crds -n velero
      kubectl delete ns velero
      # Allow time for deletion to occur
      sleep 30
    EOT
    on_failure = continue
  }
}
