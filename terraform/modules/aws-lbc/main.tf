resource "helm_release" "aws_load_balancer_controller" {
  name              = "aws-load-balancer-controller"
  repository        = "https://aws.github.io/eks-charts"
  chart             = "aws-load-balancer-controller"
  version           = "1.11.0"
  namespace         = var.namespace
  create_namespace  = var.create_namespace

  values = [
    templatefile("${path.module}/template/values.yaml", {
      cluster_name    = var.cluster_name
      region          = var.region
      vpc_id          = var.vpc_id
      service_account = var.service_account_name
      aws_lbc_role_arn = module.aws_lb_controller_irsa.iam_role_arn
    })
  ]

  depends_on = [
    kubernetes_namespace.aws_load_balancer_controller
  ]
}

resource "kubernetes_namespace" "aws_load_balancer_controller" {
  count = var.create_namespace ? 1 : 0
  
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
      "app.kubernetes.io/part-of"    = "aws-load-balancer-controller"
    }
  }
}
