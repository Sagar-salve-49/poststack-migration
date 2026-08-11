output "db_instance_id" {
  description = "RDS PostgreSQL instance ID."
  value       = aws_db_instance.postgres.id
}

output "db_endpoint" {
  description = "RDS PostgreSQL endpoint."
  value       = aws_db_instance.postgres.address
}

output "db_port" {
  description = "RDS PostgreSQL port."
  value       = aws_db_instance.postgres.port
}

output "db_security_group_id" {
  description = "RDS security group ID."
  value       = aws_security_group.rds.id
}

output "db_secret_arn" {
  description = "Secrets Manager ARN containing the RDS master credentials."
  value       = aws_db_instance.postgres.master_user_secret[0].secret_arn
}
