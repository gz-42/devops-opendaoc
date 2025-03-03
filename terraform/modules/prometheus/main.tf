resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "${var.prometheus_namespace}"
  create_namespace = false
  version    = "45.7.1"
  values = [
    templatefile("${path.module}/template/values.yaml", {
      grafana_host                            = var.grafana_host
      grafana_pwd                             = var.grafana_pwd
      grafana_ingress_enabled                 = var.grafana_ingress_enabled
      grafana_ingress_tls_acme_enabled        = var.grafana_ingress_tls_acme_enabled
      grafana_ingress_ssl_passthrough_enabled = var.grafana_ingress_ssl_passthrough_enabled
      grafana_ingress_class                   = var.grafana_ingress_class
      profile                                 = var.profile
    })
  ]
  
  timeout = 2000

  set {
    name  = "podSecurityPolicy.enabled"
    value = true
  }

  set {
    name  = "server.persistentVolume.enabled"
    value = false
  }

  set {
    name = "server.resources"
    value = yamlencode({
      limits = {
        cpu    = "200m"
        memory = "50Mi"
      }
      requests = {
        cpu    = "100m"
        memory = "30Mi"
      }
    })
  }
}

 data "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = helm_release.prometheus.namespace
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