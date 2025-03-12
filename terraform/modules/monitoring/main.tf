resource "helm_release" "kube-prometheus-stack" {
  name              = "kube-prometheus-stack"
  repository        = "https://prometheus-community.github.io/helm-charts"
  chart             = "kube-prometheus-stack"
  namespace         = "${var.monitoring_namespace}"
  create_namespace  = true
  version           = "69.8.2"
  timeout           = 2000

  values = [
    templatefile("${path.module}/template/values.yaml", {
      profile                                 = var.profile
      slack_webhook                           = var.slack_webhook
      slack_channel                           = var.slack_channel
      grafana_hostname                        = var.grafana_hostname
      grafana_pwd                             = var.grafana_pwd
      grafana_ingress_enabled                 = var.grafana_ingress_enabled
      grafana_ingress_tls_acme_enabled        = var.grafana_ingress_tls_acme_enabled
      grafana_ingress_ssl_passthrough_enabled = var.grafana_ingress_ssl_passthrough_enabled
      grafana_ingress_class                   = var.grafana_ingress_class
      grafana_tls_secret                      = var.grafana_tls_secret
    })
  ]
}
