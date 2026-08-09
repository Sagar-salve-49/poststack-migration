variable "aws_region" {
  description = "AWS region."
  type        = string
}

variable "project_name" {
  description = "Project name."
  type        = string
}

variable "environment" {
  description = "Deployment environment."
  type        = string
}

variable "vpc_id" {
  description = "Application VPC ID."
  type        = string
}

variable "private_app_subnet_ids" {
  description = "Private application subnet IDs."
  type        = list(string)
}

variable "app_security_group_id" {
  description = "Security group for ECS application tasks."
  type        = string
}

variable "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  type        = string
}

variable "ecs_task_role_arn" {
  description = "ECS task role ARN."
  type        = string
}

variable "alb_target_group_arn" {
  description = "Existing ALB target group ARN."
  type        = string
}

variable "container_port" {
  description = "Application container port."
  type        = number
  default     = 8080
}

variable "desired_count" {
  description = "Number of ECS tasks."
  type        = number
  default     = 2
}

variable "image_tag" {
  description = "Application container image tag."
  type        = string
  default     = "v1"
}
