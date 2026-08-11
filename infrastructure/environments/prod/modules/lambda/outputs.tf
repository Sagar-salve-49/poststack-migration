output "lambda_function_name" {
  description = "Lambda function name."
  value       = aws_lambda_function.app.function_name
}

output "lambda_function_arn" {
  description = "Lambda function ARN."
  value       = aws_lambda_function.app.arn
}

output "lambda_security_group_id" {
  description = "Lambda security group ID."
  value       = aws_security_group.lambda.id
}

output "lambda_role_arn" {
  description = "Lambda execution role ARN."
  value       = aws_iam_role.lambda.arn
}

output "lambda_log_group_name" {
  description = "Lambda CloudWatch log group."
  value       = aws_cloudwatch_log_group.lambda.name
}
