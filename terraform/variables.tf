#Global Variables
variable "region" {
  description = "AWS region"
  default     = "eu-west-3"
  type        = string
}

variable "namespace" {
  description = "L'espace de noms de projet à utiliser pour la dénomination unique des ressources"
  default     = "devops-opendaoc"
  type        = string
}

variable "root_domain_name" {
  description = "nom de la racine du domaine"
  default     = "gz-42.com"
  type        = string
}

#EKS Variables
variable "ami_type" {
  description = "Type d'image AMI AWS pour les serveurs eks"
  default     = "AL2023_x86_64_STANDARD"
  type        = string
}

variable "instance_type" {
  description = "Type d'instance pour les serveurs eks"
  default     = "t3a.medium"
  type        = string
}

variable "instance_number" {
  description = "Nombre d'instance pour les serveurs eks"
  default     = 2
  type        = number
}

variable "profile" {
  description = "environnement"
  default     = "prod"
  type        = string
}

variable "cluster_name" {
  description = "nom du cluster"
  default     = "devops-opendaoc-cluster"
  type        = string
}

#Cert-Manager Variables
variable "certificate_bucket" {
  description = "Bucket S3 pour stocker les certificats"
  type        = string
  default     = "devops-opendaoc-certificates"
}

#ArgoCD Variables
variable "devops_opendaoc_repo" {
  description = "depot git de la chart helm du projet devops-opendaoc"
  default     = "https://github.com/gz-42/devops-opendaoc.git"
  type        = string
}

variable "argocd_admin_password" {
  description = "Initial admin password for ArgoCD"
  type        = string
  sensitive   = true
  default = "$2a$10$q1/v/Rdo.VJRdhrTqNAXa.9I/fr5LTRnOKIbQUXGIgqejFSrOPxpm%"
#  default     = "{{ secret.ARGOCD_ADMIN_PASSWORD }}"
}
#Kube-Prometheus-Stack Variables
variable "grafana_pwd" {
  description = "grafana admin pass"
  type        = string
  sensitive   = true
  default = "datascientest2025"
#  default     = "{{ secret.GRAFANA_ADMIN_PASSWORD }}"
}