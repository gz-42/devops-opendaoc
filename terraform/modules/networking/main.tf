data "aws_availability_zones" "available" {}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.1.2"

  name                    = "${var.namespace}-vpc"
  cidr                    = var.vpc_cidr
  azs                     = data.aws_availability_zones.available.names
  private_subnets         = var.private_subnet_cidrs
  public_subnets          = var.public_subnet_cidrs
  enable_nat_gateway      = true
  single_nat_gateway      = true
  one_nat_gateway_per_az  = false
  enable_dns_hostnames    = true
  enable_dns_support      = true

  tags = {
    Name = "${var.namespace}-vpc"
  }

  public_subnet_tags = {
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/devops-opendaoc-cluster" = "shared"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/devops-opendaoc-cluster" = "shared"

  }
}

# Create a security group for public-facing resources
resource "aws_security_group" "public_sg" {
  name          = "${var.namespace}-public-sg"
  description   = "Security group for public-facing resources"
  vpc_id        = module.vpc.vpc_id

# Allow SSH access from anywhere
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "SSH access"
  }
  tags = {
    Name = "${var.namespace}-public-sg"
  }
}

resource "aws_security_group" "private_sg" {
  name          = "${var.namespace}-private-sg"
  description   = "Security group for private resources"
  vpc_id        = module.vpc.vpc_id

  ingress {
    description = "SSH uniquement a partir de clients VPC internes"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "HTTP uniquement a partir de clients VPC internes"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
  ingress {
    description = "HTTP uniquement a partir de clients VPC internes"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }
# Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.namespace}-private-sg"
  }
}
resource "aws_security_group" "opendaoc_core_lb_sg" {
  name        = "${var.namespace}-opendaoc-core-lb-sg"
  description = "Security group for OpenDAoC Core Load Balancer"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "OpenDAoC Core TCP Port"
    from_port   = var.opendaoc_core_tcp_port
    to_port     = var.opendaoc_core_tcp_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "OpenDAoC Core UDP Port"
    from_port   = var.opendaoc_core_udp_port
    to_port     = var.opendaoc_core_udp_port
    protocol    = "udp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name = "${var.namespace}-opendaoc-core-lb-sg"
  }
}
