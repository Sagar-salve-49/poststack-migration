variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Environment name."
  type        = string
}

variable "vpc_id" {
  description = "Application VPC ID."
  type        = string
}

variable "vpc_cidr" {
  description = "Application VPC CIDR."
  type        = string
}

variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  type        = list(string)
}

variable "container_port" {
  description = "Port exposed by the application container."
  type        = number
  default     = 8080

  validation {
    condition     = var.container_port >= 1 && var.container_port <= 65535
    error_message = "container_port must be between 1 and 65535."
  }
}
