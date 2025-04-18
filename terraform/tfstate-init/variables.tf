variable "region" {
  description = "AWS region"
  type        = string
  sensitive   = true
  default     = "{{ secret.AWS_REGION }}"
}

variable "prefix" {
  description = "Prefix for resources"
  type        = string
  sensitive   = true
  default     = "{{ secret.TF_STATE_PREFIX }}"  
}
