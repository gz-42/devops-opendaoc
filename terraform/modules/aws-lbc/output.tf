output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.aws_load_balancer_controller.name
}

output "helm_release_namespace" {
  description = "Namespace of the Helm release"
  value       = helm_release.aws_load_balancer_controller.namespace
}

output "service_account_name" {
  description = "Name of the service account"
  value       = "aws-load-balancer-controller"
}

output "service_account_role_arn" {
  description = "ARN of the IAM role for the service account"
  value       = module.aws_lb_controller_irsa.iam_role_arn
}