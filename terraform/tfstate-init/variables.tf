variable "region" {
  description = "AWS region"
  default     = "eu-west-3"
  type        = string
}

variable "namespace" {
  description = "Project namespace for naming resources"
  default     = "devops-opendaoc"
  type        = string
}