variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
  sensitive   = true
}

variable "project_name" {
  description = "Project name"
  type        = string
  sensitive   = true
}

variable "group_users" {
  description = "List of IAM users to add to the EKS cluster"
  type        = list(string)
  sensitive   = true
}

variable "region" {
  description = "AWS region"
  type        = string
  sensitive   = true
}

variable "ami_type" {
  description = "Type of Amazon Machine Image (AMI) for the EKS nodes"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
}

variable "instance_number" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "profile" {
  description = "Environment profile (dev, prod, etc.)"
  type        = string
}

variable "vpc" {
  description = "VPC object from the networking module"
  type        = any
  sensitive   = true
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
  sensitive   = true
}

variable "sg_private_id" {
  description = "Security group ID for private resources"
  type        = string
  sensitive   = true
}