variable "project_name" {
  description = "Prefix for resource naming"
  type        = string
  sensitive   = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  sensitive   = true
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  sensitive   = true
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  sensitive   = true
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  sensitive   = true
}