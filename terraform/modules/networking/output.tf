output "vpc" {
  description = "The VPC object"
  value       = module.vpc
}

output "vpc_id" {
  description = "The ID of the VPC"
  value       = module.vpc.vpc_id
}

output "vpc_cidr_block" {
  description = "The CIDR block of the VPC"
  value       = module.vpc.vpc_cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = module.vpc.public_subnets
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = module.vpc.private_subnets
}

output "sg_pub_id" {
  description = "ID of the public security group"
  value       = aws_security_group.public_sg.id
}

output "sg_priv_id" {
  description = "ID of the private security group"
  value       = aws_security_group.private_sg.id
}

output "opendaoc_core_lb_sg_id" {
  description = "ID of the security group for the OpenDAoC Core Load Balancer"
  value       = aws_security_group.opendaoc_core_lb_sg.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways created by the VPC module"
  value       = module.vpc.natgw_ids
}
