output "load_balancer_hostname" {
  description = "The hostname of the load balancer for Ingress and Gameserver"
  value       = data.kubernetes_service.nginx_controller.status[0].load_balancer[0].ingress[0].hostname
}

data "kubernetes_service" "nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "ingress-nginx"
  }
  depends_on = [helm_release.nginx_ingress]
}