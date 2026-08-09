output "pipeline_name" {
  description = "CodePipeline name."
  value       = aws_codepipeline.app.name
}

output "pipeline_arn" {
  description = "CodePipeline ARN."
  value       = aws_codepipeline.app.arn
}

output "artifact_bucket_name" {
  description = "CodePipeline artifact bucket."
  value       = aws_s3_bucket.pipeline_artifacts.bucket
}

output "codepipeline_role_arn" {
  description = "CodePipeline IAM role ARN."
  value       = aws_iam_role.codepipeline.arn
}
