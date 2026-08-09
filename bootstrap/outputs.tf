output "aws_account_id" {
  description = "AWS account ID."
  value       = data.aws_caller_identity.current.account_id
}

output "terraform_state_bucket" {
  description = "Terraform remote state S3 bucket."
  value       = aws_s3_bucket.terraform_state.bucket
}

output "terraform_execution_role_arn" {
  description = "Terraform execution IAM role ARN."
  value       = aws_iam_role.terraform_execution.arn
}

output "terraform_state_kms_key_arn" {
  description = "KMS key ARN used to encrypt Terraform state."
  value       = aws_kms_key.terraform_state.arn
}
