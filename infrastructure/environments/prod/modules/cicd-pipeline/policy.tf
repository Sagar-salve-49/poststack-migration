
data "aws_iam_policy_document" "codepipeline" {

  statement {
    sid    = "S3Artifacts"
    effect = "Allow"

    actions = [
      "s3:GetBucketVersioning"
    ]

    resources = [
      aws_s3_bucket.pipeline_artifacts.arn
    ]
  }

  statement {
    sid    = "S3Objects"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:PutObject"
    ]

    resources = [
      "${aws_s3_bucket.pipeline_artifacts.arn}/*"
    ]
  }

  statement {
    sid    = "UseGitHubConnection"
    effect = "Allow"

    actions = [
      "codeconnections:UseConnection"
    ]

    resources = [
      var.github_connection_arn
    ]
  }

  statement {
    sid    = "CodeBuild"
    effect = "Allow"

    actions = [
      "codebuild:StartBuild",
      "codebuild:BatchGetBuilds"
    ]

    resources = [
      "arn:aws:codebuild:${var.aws_region}:${data.aws_caller_identity.current.account_id}:project/${var.codebuild_project_name}"
    ]
  }

  statement {
    sid    = "ECSDeploy"
    effect = "Allow"

    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:RegisterTaskDefinition",
      "ecs:UpdateService",
      "ecs:TagResource"
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid    = "PassECSTaskRoles"
    effect = "Allow"

    actions = [
      "iam:PassRole"
    ]

    resources = [
      var.ecs_task_execution_role_arn,
      var.ecs_task_role_arn
    ]

    condition {
      test     = "StringEquals"
      variable = "iam:PassedToService"
      values   = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy" "codepipeline" {
  name   = "${var.project_name}-${var.environment}-codepipeline"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline.json
}
