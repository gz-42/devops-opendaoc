variable "namespace" {
  description = "Prefix for resource naming"
  type        = string
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.242.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "CIDR blocks for public subnets"
  type        = list(string)
  default     = ["10.242.0.0/24", "10.242.1.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDR blocks for private subnets"
  type        = list(string)
  default     = ["10.242.3.0/24", "10.242.4.0/24"]
}

variable "opendaoc_core_tcp_port" {
  description = "TCP ports for game server"
  type        = number
  default     = 10300
}

variable "opendaoc_core_udp_port" {
  description = "UDP ports for game server"
  type        = number
  default     = 10400
}