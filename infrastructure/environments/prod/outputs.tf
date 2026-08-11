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
  value       = "infrastructure/prod/terraform.tfstate"
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
  description = "ECS application task role ARN."
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

output "rds_instance_id" {
  description = "RDS PostgreSQL instance ID."
  value       = module.rds.db_instance_id
}

output "rds_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = module.rds.db_endpoint
}

output "rds_port" {
  description = "RDS PostgreSQL port."
  value       = module.rds.db_port
}

output "rds_security_group_id" {
  description = "RDS security group ID."
  value       = module.rds.db_security_group_id
}

output "rds_secret_arn" {
  description = "RDS master credentials secret ARN."
  value       = module.rds.db_secret_arn
}

output "lambda_function_name" {
  description = "Lambda function name."
  value       = module.lambda.lambda_function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = module.lambda.lambda_function_arn
}

output "lambda_security_group_id" {
  description = "Lambda security group ID."
  value       = module.lambda.lambda_security_group_id
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN."
  value       = module.lambda.lambda_role_arn
}

output "lambda_log_group_name" {
  description = "Lambda CloudWatch log group."
  value       = module.lambda.lambda_log_group_name
}
