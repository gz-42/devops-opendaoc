variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
}

variable "vpc_id" {
  description = "ID of the VPC where the EKS cluster is located"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace to deploy the controller into"
  type        = string
  default     = "kube-system"
}

variable "service_account_name" {
  description = "Name of the Kubernetes service account for the controller"
  type        = string
  default     = "aws-load-balancer-controller"
}


variable "create_namespace" {
  description = "Whether to create the namespace"
  type        = bool
  default     = false
}

variable "oidc_provider_arn" {
  description = "ARN of the OIDC provider associated with the EKS cluster"
  type        = string
}