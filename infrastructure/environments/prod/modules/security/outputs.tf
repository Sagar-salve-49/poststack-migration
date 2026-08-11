output "alb_security_group_id" {
  description = "Security group ID for the application ALB."
  value       = aws_security_group.alb.id
}

output "app_security_group_id" {
  description = "Security group ID for application ECS tasks."
  value       = aws_security_group.app.id
}

output "vpc_endpoint_security_group_id" {
  description = "Security group ID for interface VPC endpoints."
  value       = aws_security_group.vpc_endpoints.id
}

output "ecs_task_execution_role_arn" {
  description = "ECS task execution role ARN."
  value       = aws_iam_role.ecs_task_execution.arn
}

output "ecs_task_role_arn" {
  description = "ECS application task role ARN."
  value       = aws_iam_role.ecs_task.arn
}

output "ecr_api_endpoint_id" {
  description = "ECR API VPC endpoint ID."
  value       = aws_vpc_endpoint.ecr_api.id
}

output "ecr_dkr_endpoint_id" {
  description = "ECR Docker VPC endpoint ID."
  value       = aws_vpc_endpoint.ecr_dkr.id
}

output "logs_endpoint_id" {
  description = "CloudWatch Logs VPC endpoint ID."
  value       = aws_vpc_endpoint.logs.id
}

output "s3_endpoint_id" {
  description = "S3 Gateway VPC endpoint ID."
  value       = aws_vpc_endpoint.s3.id
}
