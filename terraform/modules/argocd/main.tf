resource "helm_release" "argocd" {
  name = "argocd"

  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  version          = "7.8.9"
  create_namespace = true

  values = [
    templatefile("${path.module}/template/values.yaml", {
      argocd_hostname                           = var.argocd_hostname
      argocd_ingress_enabled                    = var.argocd_ingress_enabled
      argocd_ingress_tls_acme_enabled           = var.argocd_ingress_tls_acme_enabled
      argocd_ingress_force_ssl_redirect_enabled = var.argocd_ingress_force_ssl_redirect_enabled
      argocd_ingress_ssl_passthrough_enabled    = var.argocd_ingress_ssl_passthrough_enabled
      argocd_ingress_class                      = var.argocd_ingress_class
      profile                                   = var.profile
    }),
    templatefile("${path.module}/template/repository_values.yaml", {
      devops_opendaoc_repo  = var.devops_opendaoc_repo
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
      profile = var.profile
      devops_opendaoc_repo  = var.devops_opendaoc_repo
      mariadb_root_password = var.mariadb_root_password
      db_connection_string  = var.db_connection_string
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