data "aws_eks_cluster_auth" "default" {
  name = var.cluster_name
}

provider "aws" {
  region = var.region
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

provider "helm" {
  kubernetes {
    host                   = module.eks.cluster_endpoint
    cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      command     = "aws"
      args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    }
  }
}

provider "kubectl" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  load_config_file       = false
  apply_retry_count      = 3
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
  }
}

terraform {
  backend "s3" {
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.86.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.1.3"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.17.0"
    }
  }
}

module "networking" {
  source                = "./modules/networking"
  project_name          = var.project_name
  cluster_name          = var.cluster_name
  vpc_cidr              = var.vpc_cidr
  public_subnet_cidrs   = var.public_subnet_cidrs
  private_subnet_cidrs  = var.private_subnet_cidrs
}

module "eks" {
  source          = "./modules/eks"
  ami_type        = var.ami_type
  instance_type   = var.instance_type
  instance_number = var.instance_number
  vpc             = module.networking.vpc
  private_subnets = module.networking.vpc.private_subnets
  sg_private_id   = module.networking.sg_priv_id
  region          = var.region
  cluster_name    = var.cluster_name
  project_name    = var.project_name
  group_users     = var.group_users
  profile         = var.profile
}

module "ingress" {
  source                    = "./modules/ingress"
  devops_opendaoc_hostname  = var.devops_opendaoc_hostname
}

module "cert_manager" {
  source  = "./modules/cert-manager"
  email   = var.email
  profile = var.profile
}

module "argocd" {
  source                = "./modules/argocd"
  devops_opendaoc_repo  = var.devops_opendaoc_repo
  profile               = var.profile
  argocd_hostname       = var.argocd_hostname
  mariadb_root_password = var.mariadb_root_password
  db_connection_string  = var.db_connection_string
  depends_on            = [module.ingress]
}

module "kube_prometheus_stack" {
  source                      = "./modules/monitoring"
  profile                     = var.profile
  slack_webhook               = var.slack_webhook
  slack_channel               = var.slack_channel
  grafana_hostname            = var.grafana_hostname
  grafana_pwd                 = var.grafana_pwd
  grafana_ingress_tls_secret  = var.grafana_ingress_tls_secret
  depends_on                  = [module.ingress]
}

module "velero" {
  source                  = "./modules/velero"
  project_name            = var.project_name
  cluster_name            = var.cluster_name
  region                  = var.region
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  bucket_name             = "${var.project_name}-velero-backups"
}
