output "load_balancer_hostname" {
  description   = "The hostname of the load balancer"
  sensitive     = true
  value         = module.ingress.load_balancer_hostname
}