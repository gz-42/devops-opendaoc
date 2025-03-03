resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.12.0"
  create_namespace = true
  timeout = 9000

  values = [
    templatefile("${path.module}/template/values.yaml", {
      certificate_namespace   = var.certificate_namespace
      certificate_secret_name = var.certificate_secret_name
    })
  ]
}