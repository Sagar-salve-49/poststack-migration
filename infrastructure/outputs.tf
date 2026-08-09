output "aws_account_id" {
  description = "AWS account ID used by Terraform."
  value       = data.aws_caller_identity.current.account_id
}

output "aws_region" {
  description = "AWS region used by Terraform."
  value       = var.aws_region
}

output "terraform_state_key" {
  description = "S3 object key used for infrastructure Terraform state."
  value       = "infrastructure/terraform.tfstate"
}

output "vpc_id" {
  description = "Application VPC ID."
  value       = module.networking.vpc_id
}

output "public_subnet_ids" {
  description = "Application public subnet IDs."
  value       = module.networking.public_subnet_ids
}

output "private_app_subnet_ids" {
  description = "Application private subnet IDs."
  value       = module.networking.private_app_subnet_ids
}

output "alb_security_group_id" {
  description = "Application ALB security group ID."
  value       = module.security.alb_security_group_id
}

output "app_security_group_id" {
  description = "Application ECS task security group ID."
  value       = module.security.app_security_group_id
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = module.security.ecs_task_execution_role_arn
}

output "ecs_task_role_arn" {
  description = "ECS task role ARN."
  value       = module.security.ecs_task_role_arn
}

output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = module.alb.alb_arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = module.alb.alb_dns_name
}

output "alb_target_group_arn" {
  description = "Application target group ARN."
  value       = module.alb.target_group_arn
}

output "ecr_repository_name" {
  description = "ECR application repository name."
  value       = module.ecs.ecr_repository_name
}

output "ecr_repository_url" {
  description = "ECR application repository URL."
  value       = module.ecs.ecr_repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name."
  value       = module.ecs.ecs_cluster_name
}

output "ecs_cluster_arn" {
  description = "ECS cluster ARN."
  value       = module.ecs.ecs_cluster_arn
}
