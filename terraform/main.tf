data "aws_eks_cluster_auth" "default" {
  name  = var.cluster_name
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
    bucket         = "devops-opendaoc-terraform-state"
    key            = "terraform.tfstate"
    region         = "eu-west-3"
    dynamodb_table = "devops-opendaoc-terraform-locks"
    encrypt        = true
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.24.0"
    }
    kubectl = {
      source  = "alekc/kubectl"
      version = ">= 2.0.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.12.0"
    }
  }
}

module "networking" {
  source    = "./modules/networking"
  namespace = var.namespace
}

module "eks" {
  source                    = "./modules/eks"
  namespace                 = var.namespace
  ami_type                  = var.ami_type
  instance_type             = var.instance_type
  instance_number           = var.instance_number
  vpc                       = module.networking.vpc
  private_subnets           = module.networking.vpc.private_subnets
  sg_private_id             = module.networking.sg_priv_id
  region                    = var.region
  cluster_name              = var.cluster_name
  profile                   = var.profile
}

module "cluster_check" {
  source       = "./modules/cluster-check"
  cluster_name = var.cluster_name
  region       = var.region
  depends_on   = [module.eks]
}

resource "kubernetes_namespace" "certmanager" {
  metadata {
    name = "certmanager"
  }
  depends_on = [module.cluster_check]
}

resource "kubernetes_namespace" "argocd" {
  metadata {
    name      = "argocd"
  }
  depends_on = [module.cluster_check]
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name      = "monitoring"
  }
  depends_on = [module.cluster_check]
}

module "cert_manager" {
  source                        = "./modules/cert_manager"
  profile                       = var.profile
  cluster_name                  = var.cluster_name
  certificate_bucket            = var.certificate_bucket
  depends_on                    = [
    module.eks,
    kubernetes_namespace.certmanager,
    kubernetes_namespace.argocd,
    kubernetes_namespace.monitoring
  ]
}

module "ingress" {
  source                  = "./modules/ingress"
  profile                 = var.profile
  namespace               = var.namespace
  certificate_secret_name = module.cert_manager.certificate_secret_name
  certificate_namespace   = module.cert_manager.certificate_namespace
  depends_on              = [module.cert_manager]  
}

module "argocd" {
  source                  = "./modules/argocd"
  devops_opendaoc_repo    = var.devops_opendaoc_repo
  profile                 = var.profile
  argocd_admin_password   = var.argocd_admin_password
  certificate_secret_name = module.cert_manager.certificate_secret_name
  certificate_namespace   = module.cert_manager.certificate_namespace
  depends_on              = [module.ingress]  
}

module "prometheus" {
  source                  = "./modules/prometheus"
  grafana_pwd             = var.grafana_pwd
  profile                 = var.profile
  root_domain_name        = var.root_domain_name
  certificate_secret_name = module.cert_manager.certificate_secret_name
  certificate_namespace   = module.cert_manager.certificate_namespace
  depends_on              = [module.ingress]
}

module "velero" {
  source                  = "./modules/velero"
  cluster_name            = var.cluster_name
  region                  = var.region
  cluster_oidc_issuer_url = module.eks.cluster_oidc_issuer_url
  bucket_name             = "${var.namespace}-velero-backups"
  depends_on              = [module.ingress]
}

module "aws_load_balancer_controller" {
  source              = "./modules/aws-lbc"
  namespace           = "kube-system"
  create_namespace    = false
  cluster_name        = module.eks.cluster_name
  region              = var.region
  vpc_id              = module.networking.vpc.vpc_id
  oidc_provider_arn   = module.eks.oidc_provider_arn
  depends_on          = [module.velero]  
}
