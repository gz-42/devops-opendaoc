resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.8.5"
  create_namespace = false

  values = [
    templatefile("${path.module}/template/values.yaml", {
      argocd_server_host                      = var.argocd_server_host
      argocd_ingress_enabled                  = var.argocd_ingress_enabled
      argocd_ingress_tls_acme_enabled         = var.argocd_ingress_tls_acme_enabled
      argocd_ingress_ssl_passthrough_enabled  = var.argocd_ingress_ssl_passthrough_enabled
      argocd_ingress_class                    = var.argocd_ingress_class
      argocd_admin_password                   = var.argocd_admin_password
      profile                                 = var.profile
    }),
    templatefile("${path.module}/template/repository_values.yaml", {
      "devops_opendaoc_repo"  = var.devops_opendaoc_repo
    })
  ]
}

resource "helm_release" "argocd-apps" {
  name = "argocd-apps"

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argocd-apps"
  namespace  = "argocd"
  version    = "2.0.2"

  values = [
    templatefile("${path.module}/template/application_values.yaml", {
      "devops_opendaoc_repo" = var.devops_opendaoc_repo
    })
  ]

  depends_on = [helm_release.argocd]
}

data "kubernetes_service" "argocd_server" {
  metadata {
    name      = "argocd-server"
    namespace = helm_release.argocd.namespace
  }
}

resource "kubernetes_secret" "imported_certificate" {
  
  metadata {
    name      = var.certificate_secret_name
    namespace = var.namespace
  }
  
  data = {
    "tls.crt" = data.kubernetes_secret.cert.data["tls.crt"]
    "tls.key" = data.kubernetes_secret.cert.data["tls.key"]
  }
  
  type = "kubernetes.io/tls"
}

data "kubernetes_secret" "cert" {
  metadata {
    name      = var.certificate_secret_name
    namespace = var.certificate_namespace
  }
}