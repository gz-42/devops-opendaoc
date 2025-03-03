resource "null_resource" "ensure_cluster_ready" {
  triggers = {
    cluster_name = var.cluster_name
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Ensuring EKS cluster ${var.cluster_name} is ready..."
      
      # Retry logic to wait for the EKS cluster to be accessible
      max_retries=30
      counter=0
      
      until aws eks describe-cluster --name ${var.cluster_name} --region ${var.region} --query "cluster.status" --output text | grep -q "ACTIVE"; do
        if [ $counter -eq $max_retries ]; then
          echo "Failed to connect to EKS cluster after $max_retries attempts"
          exit 1
        fi
        echo "Waiting for EKS cluster ${var.cluster_name} to be active... (attempt $counter/$max_retries)"
        counter=$((counter+1))
        sleep 10
      done
      
      # Update kubeconfig
      aws eks update-kubeconfig --name ${var.cluster_name} --region ${var.region}
      
      # Test connection to nodes and wait for at least one node to be ready
      echo "Waiting for at least one node to be ready..."
      max_retries=30
      counter=0
      
      until kubectl get nodes -o jsonpath='{.items[*].status.conditions[?(@.type=="Ready")].status}' | grep -q "True"; do
        if [ $counter -eq $max_retries ]; then
          echo "No ready nodes found after $max_retries attempts"
          exit 1
        fi
        echo "Waiting for nodes to be ready... (attempt $counter/$max_retries)"
        counter=$((counter+1))
        sleep 10
      done
      
      echo "EKS cluster ${var.cluster_name} is ready with nodes available"
    EOT
  }
}