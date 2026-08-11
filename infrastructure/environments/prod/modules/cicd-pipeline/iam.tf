data "aws_iam_policy_document" "codepipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "codepipeline" {
  name = "${var.project_name}-${var.environment}-codepipeline"

  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-codepipeline-role"
    Purpose     = "CICD"
    Environment = var.environment
  }
}
