data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

resource "aws_kms_key" "ecs" {
  description             = "KMS key for ${var.project_name}-${var.environment} ECS application logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-ecs-kms"
    Purpose = "ECSApplicationLogsEncryption"
  })
}

resource "aws_kms_key_policy" "ecs" {
  key_id = aws_kms_key.ecs.id

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableAccountAdministration"
        Effect = "Allow"

        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }

        Action   = "kms:*"
        Resource = "*"
      },
      {
        Sid    = "AllowCloudWatchLogs"
        Effect = "Allow"

        Principal = {
          Service = "logs.${data.aws_region.current.region}.amazonaws.com"
        }

        Action = [
          "kms:Encrypt",
          "kms:Decrypt",
          "kms:ReEncrypt*",
          "kms:GenerateDataKey*",
          "kms:DescribeKey"
        ]

        Resource = "*"
      }
    ]
  })
}

resource "aws_kms_alias" "ecs" {
  name          = "alias/${local.name_prefix}-ecs"
  target_key_id = aws_kms_key.ecs.key_id
}
