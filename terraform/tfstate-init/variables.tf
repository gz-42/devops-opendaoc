variable "region" {
  description = "AWS region"
  default     = "eu-west-3"
  type        = string
  sensitive   = true
#  default     = "{{ secret.AWS_REGION }}"
}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
  sensitive   = true
  default     = "devops-opendaoc"
#  default     = "{{ secret.TF_STATE_PREFIX }}"  
}