module "cert_manager" {
  source        = "terraform-iaac/cert-manager/kubernetes"

  namespace_name                          = var.cert_manager_namespace
  create_namespace                        = false
  cluster_issuer_email                    = "keo@gz-42.com"
  solvers = []
  certificates= {}
}

resource "kubernetes_service_account" "cert_s3_importer" {
  metadata {
    name      = "cert-s3-importer"
    namespace = var.cert_manager_namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.cert_s3_importer.arn
    }
  }
  depends_on = [module.cert_manager]
}

# Get the OIDC provider URL from the EKS cluster
data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

data "aws_iam_policy_document" "cert_s3_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test     = "StringEquals"
      variable = "${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:${var.cert_manager_namespace}:cert-s3-importer"]
    }

    principals {
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${replace(data.aws_eks_cluster.cluster.identity[0].oidc[0].issuer, "https://", "")}"]
      type        = "Federated"
    }
  }
}


data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

# Create IAM role for S3 access
resource "aws_iam_role" "cert_s3_importer" {
  name               = "cert-s3-importer-${var.cluster_name}"
  assume_role_policy = data.aws_iam_policy_document.cert_s3_assume_role_policy.json
}

# Policy to allow S3 access
resource "aws_iam_role_policy" "cert_s3_policy" {
  name = "cert-s3-access-policy"
  role = aws_iam_role.cert_s3_importer.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Effect = "Allow"
        Resource = [
          "arn:aws:s3:::${var.certificate_bucket}",
          "arn:aws:s3:::${var.certificate_bucket}/*"
        ]
      }
    ]
  })
}

# Create role to allow cert-s3-importer to create/manage secrets
resource "kubernetes_role" "cert_s3_importer_role" {
  metadata {
    name      = "cert-s3-importer-role"
    namespace = var.cert_manager_namespace
  }

  rule {
    api_groups = [""]
    resources  = ["secrets"]
    verbs      = ["create", "update", "patch", "get"]
  }
}

resource "kubernetes_role_binding" "cert_s3_importer_binding" {
  metadata {
    name      = "cert-s3-importer-binding"
    namespace = var.cert_manager_namespace
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role.cert_s3_importer_role.metadata[0].name
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.cert_s3_importer.metadata[0].name
    namespace = var.cert_manager_namespace
  }
}

resource "null_resource" "wait_for_cert_manager" {
  depends_on = [module.cert_manager] 
  
  provisioner "local-exec" {
    command = <<-EOT
      # Ensure kubeconfig is properly set
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${data.aws_region.current.name}
      
      # Wait for deployments to be ready with more reliable checking
      echo "Waiting for cert-manager deployment to be available..."
      kubectl wait --for=condition=available --timeout=300s deployment/cert-manager -n ${var.cert_manager_namespace} 
      
      echo "Waiting for cert-manager-webhook deployment to be available..."
      kubectl wait --for=condition=available --timeout=300s deployment/cert-manager-webhook -n ${var.cert_manager_namespace}
      
      # Retry logic for certificates CRD
      max_retries=30
      counter=0
      
      until kubectl get crd certificates.cert-manager.io 2>/dev/null; do
        if [ $counter -eq $max_retries ]; then
          echo "Cert-manager CRDs not available after $max_retries attempts"
          exit 1
        fi
        echo "Waiting for cert-manager CRDs to be available... (attempt $counter/$max_retries)"
        counter=$((counter+1))
        sleep 10
      done
      
      echo "Cert-manager CRDs are ready"
    EOT
  }
}

data "kubernetes_namespace" "target_namespaces" {
  for_each = toset(var.certificate_target_namespaces)
  
  metadata {
    name = each.key
  }
}

resource "null_resource" "import_certificate" {
  depends_on = [
    kubernetes_service_account.cert_s3_importer,
    kubernetes_role_binding.cert_s3_importer_binding,
    null_resource.wait_for_cert_manager,
    data.kubernetes_namespace.target_namespaces
  ]

  provisioner "local-exec" {
    command = <<-EOT
      # Wait for cert-manager CRDs to be ready
      kubectl wait --for=condition=established crd/certificates.cert-manager.io --timeout=120s
      
      # Create TLS secret directly - fetch certificate from S3 using AWS CLI
      aws s3 cp s3://${var.certificate_bucket}/certificate.crt /tmp/certificate.crt
      aws s3 cp s3://${var.certificate_bucket}/private.key /tmp/private.key
      
      # Create the secret in the cert-manager namespace
      kubectl create secret tls ${var.certificate_secret_name} \
        --cert=/tmp/certificate.crt \
        --key=/tmp/private.key \
        --namespace=${var.cert_manager_namespace} \
        --dry-run=client -o yaml | kubectl apply -f -
      
      # Copy the secret to target namespaces
      for ns in ${join(" ", var.certificate_target_namespaces)}; do
        kubectl get secret ${var.certificate_secret_name} -n ${var.cert_manager_namespace} -o yaml | \
          sed "s/namespace: ${var.cert_manager_namespace}/namespace: $ns/" | \
          kubectl apply -f -
      done
      
      # Create the Certificate resource for cert-manager
      cat <<EOF | kubectl apply -f -
      apiVersion: cert-manager.io/v1
      kind: Certificate
      metadata:
        name: imported-certificate
        namespace: ${var.cert_manager_namespace}
      spec:
        secretName: ${var.certificate_secret_name}
        dnsNames:
        - ${join("\n        - ", var.certificate_dns_names)}
        isCA: false
        secretTemplate:
          annotations:
            cert-manager.io/issue-temporary-certificate: "false"
            cert-manager.io/alt-names: "${join(",", var.certificate_dns_names)}"
      EOF
      
      # Clean up temporary files
      rm -f /tmp/certificate.crt /tmp/private.key
    EOT
  }
}