output "argocd_grafana_load_balancer_hostname" {
  description = "The hostname of the load balancer"
  value       = module.ingress.load_balancer_hostname
}