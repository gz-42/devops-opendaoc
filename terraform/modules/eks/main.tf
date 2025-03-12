module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.33"

  cluster_name    = var.cluster_name
  cluster_version = "1.32"

  cluster_endpoint_public_access = true
  cluster_endpoint_private_access = true

  create_kms_key              = false
  create_cloudwatch_log_group = false
  cluster_encryption_config   = {}
  
  cluster_addons = {
    coredns = {
      most_recent = true
    }
    kube-proxy = {
      most_recent = true
    }
    vpc-cni = {
      most_recent = true
    }
    aws-ebs-csi-driver = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
    snapshot-controller = {
      most_recent              = true
      service_account_role_arn = module.ebs_csi_irsa.iam_role_arn
    }
  }

  vpc_id      = var.vpc.vpc_id
  subnet_ids  = var.private_subnets

  eks_managed_node_group_defaults = {
    ami_type       = "${var.ami_type}"
    instance_types = ["${var.instance_type}"]
    sg_private_ids = ["${var.sg_private_id}"]
  }

  eks_managed_node_groups = {
    devops-opendaoc = {
      min_size        = 1
      max_size        = 3
      desired_size    = "${var.instance_number}"
      instance_types  = ["${var.instance_type}"]
      capacity_type   = "ON_DEMAND"
    }
  }

  enable_irsa = true
  enable_cluster_creator_admin_permissions = true

  tags = {
    env       = var.profile
    terraform = "true"
    type      = "${var.project_name}-opendaoc-eks"
  }
}

provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    args        = ["eks", "get-token", "--cluster-name", var.cluster_name]
    command     = "aws"
  }
}

module "aws_auth" {
  source        = "terraform-aws-modules/eks/aws//modules/aws-auth"
  version       = "~> 20.33"
  create_aws_auth_configmap = true
  manage_aws_auth_configmap = true

  aws_auth_roles = [
    {
      rolearn  = module.eks.cluster_iam_role_arn
      username = module.eks.cluster_iam_role_name
      groups   = ["system:masters"]
    },
  ]
}

resource "kubernetes_storage_class" "gp3" {
  metadata {
    name = "gp3"
    annotations = {
      "storageclass.kubernetes.io/is-default-class" = "true"
    }
  }

  storage_provisioner    = "kubernetes.io/aws-ebs"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true
  volume_binding_mode    = "WaitForFirstConsumer"
  
  parameters = {
    type       = "gp3"
    encrypted  = "true"
    fsType     = "ext4"
    iops       = "3000"
    throughput = "125"
  }
}