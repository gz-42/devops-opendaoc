output "certificate_secret_name" {
  description = "Name of the TLS secret containing the imported certificate"
  value       = var.certificate_secret_name
}

output "certificate_namespace" {
  description = "Namespace where the certificate secret is stored"
  value       = var.cert_manager_namespace
}