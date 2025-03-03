variable "namespace" {
  description = "Namespace/prefix for resources"
  type        = string
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
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
}

variable "private_subnets" {
  description = "List of private subnet IDs for the EKS cluster"
  type        = list(string)
}

variable "sg_private_id" {
  description = "Security group ID for private resources"
  type        = string
}