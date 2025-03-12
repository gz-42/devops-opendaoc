resource "helm_release" "nginx_ingress" {
  name       = "ingress-nginx"

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.12.0"
  create_namespace = true
  timeout = 600
  
  values = [
    templatefile("${path.module}/template/values.yaml", {
      devops_opendaoc_hostname   = var.devops_opendaoc_hostname
    })
  ]
}