#Global Variables
variable "region" {
  description = "AWS region"
  type        = string
  sensitive   = true
  default     = "{{ secret.AWS_REGION }}"
}

variable "project_name" {
  description = "Project name"
  type        = string
  sensitive   = true
  default     = "{{ secret.PROJECT_NAME }}"
}

variable "root_domain_name" {
  description = "Root domain name"
  type        = string
  sensitive   = true
  default     = "{{ secret.DOMAIN_NAME }}"
}

#Networking Variables
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  sensitive   = true
  default     = "{{ secret.VPC_CIDR }}"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  sensitive   = true
  default     = ["{{ secret.VPC_PUBLIC_SUBNETS }}"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  sensitive   = true
  default     = ["{{ secret.VPC_PRIVATE_SUBNETS }}"]
}

#EKS Variables
variable "ami_type" {
  description = "AWS AMI Image Type for EKS servers"
  default     = "AL2023_x86_64_STANDARD"
  type        = string
}

variable "instance_type" {
  description = "Instance type for EKS servers"
  default     = "t3a.large"
  type        = string
}

variable "instance_number" {
  description = "Number of instances for EKS servers"
  default     = 2
  type        = number
}

variable "profile" {
  description = "Name of the environment"
  default     = "prod"
  type        = string
}

variable "cluster_name" {
  description = "Name of the cluster"
  type        = string
  sensitive   = true
 default     = "{{ secret.CLUSTER_NAME }}"
}

variable "group_users" {
  description = "List of IAM users to add to the EKS cluster"
  type        = list(string)
  sensitive   = true
  default     = ["{{ secret.GROUP_USERS }}"]
}

#Cert-Manager Variables
variable "email" {
  description = "Email address for Let's Encrypt registration"
  type        = string
  sensitive   = true
  default     = "{{ secret.EMAIL }}"
}

#Ingress Variables
variable "devops_opendaoc_hostname" {
  description = "Hostname for the GameServer"
  type        = string
  sensitive   = true
  default     = "{{ secret.DEVOPS_OPENDAOC_HOSTNAME }}"
}

#ArgoCD Variables
variable "argocd_hostname" {
  description = "Hostname for ArgoCD"
  type        = string
  sensitive   = true
  default     = "{{ secret.ARGOCD_HOSTNAME }}"
}

variable "devops_opendaoc_repo" {
  description = "Git repository for devops-opendaoc project"
  default     = "https://github.com/gz-42/devops-opendaoc.git"
  type        = string
}

variable "mariadb_root_password" {
  description = "Root password for mariadb"
  type        = string
  sensitive   = true
  default     = "{{ secret.MARIADB_ROOT_PASSWORD }}"
}

variable "db_connection_string" {
  description = "Connection string for opendaoc-core"
  type        = string
  sensitive   = true
  default     = "{{ secret.DB_CONNECTION_STRING }}"
}

#Kube-Prometheus-Stack Variables
variable "grafana_hostname" {
  description = "Hostname for Grafana"
  type        = string
  sensitive   = true
  default     = "{{ secret.GRAFANA_HOSTNAME }}"
}

variable "grafana_pwd" {
  description = "Grafana admin password"
  type        = string
  sensitive   = true
  default     = "{{ secret.GRAFANA_ADMIN_PASSWORD }}"
}

variable "grafana_tls_secret" {
  description = "Secret name for grafana TLS cert"
  type        = string
  sensitive   = true
  default     = "{{ secret.GRAFANA_TLS_SECRET }}"
}

variable "slack_webhook" {
  description = "Slack webhook for alerts"
  type        = string
  sensitive   = true
  default     = "{{ secret.SLACK_WEBHOOK }}"
}

variable "slack_channel" {
  description = "Slack channel target for alerts"
  type        = string
  sensitive   = true
  default     = "{{ secret.SLACK_CHANNEL }}"
}
