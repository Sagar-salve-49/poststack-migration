variable "aws_region" {
  description = "AWS region for Terraform bootstrap resources."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "Project name."
  type        = string
  default     = "poststack-migration"

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "project_name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Bootstrap environment name."
  type        = string
  default     = "management"
}
