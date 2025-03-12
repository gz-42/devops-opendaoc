data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                    = "${var.project_name}-vpc"
  cidr                    = var.vpc_cidr
  azs                     = data.aws_availability_zones.available.names
  private_subnets         = var.private_subnet_cidrs
  public_subnets          = var.public_subnet_cidrs
  enable_nat_gateway      = true

  public_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/elb" = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
    "kubernetes.io/role/internal-elb" = 1
  }
}

resource "aws_security_group" "public_sg" {
  name          = "${var.project_name}-public-sg"
  description   = "Security group for public-facing resources"
  vpc_id        = module.vpc.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name          = "${var.project_name}-private-sg"
  description   = "Security group for private resources"
  vpc_id        = module.vpc.vpc_id

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "${var.project_name}-private-sg"
  }
}
