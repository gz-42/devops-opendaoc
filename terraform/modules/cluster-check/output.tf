output "cluster_ready" {
  description = "Indicator that the cluster is ready"
  value       = null_resource.ensure_cluster_ready.id
}