data "aws_region" "current" {}

resource "aws_kms_key" "waf_logs" {
  description             = "KMS key for ${var.project_name}-${var.environment} WAF CloudWatch logs"
  deletion_window_in_days = 30
  enable_key_rotation     = true

  policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Sid    = "EnableRootAccountPermissions"
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

        Condition = {
          ArnLike = {
            "kms:EncryptionContext:aws:logs:arn" = "arn:aws:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:aws-waf-logs-*"
          }
        }
      }
    ]
  })

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.environment}-waf-logs-kms"
    Purpose = "WAFLogs"
  })
}

resource "aws_kms_alias" "waf_logs" {
  name          = "alias/${var.project_name}-${var.environment}-waf-logs"
  target_key_id = aws_kms_key.waf_logs.key_id
}

resource "aws_wafv2_web_acl" "application" {
  name  = "${var.project_name}-${var.environment}-alb-waf"
  scope = "REGIONAL"

  default_action {
    allow {}
  }

  rule {
    name     = "AWSManagedRulesCommonRuleSet"
    priority = 10

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-common"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "AWSManagedRulesKnownBadInputsRuleSet"
    priority = 20

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "${var.project_name}-${var.environment}-known-bad-inputs"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.project_name}-${var.environment}-waf"
    sampled_requests_enabled   = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-waf"
  })
}

resource "aws_wafv2_web_acl_association" "application" {
  resource_arn = aws_lb.application.arn
  web_acl_arn  = aws_wafv2_web_acl.application.arn
}

resource "aws_cloudwatch_log_group" "waf" {
  name              = "aws-waf-logs-${var.project_name}-${var.environment}"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.waf_logs.arn

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.environment}-waf-logs"
    Purpose = "WAFLogs"
  })
}

resource "aws_wafv2_web_acl_logging_configuration" "application" {
  resource_arn = aws_wafv2_web_acl.application.arn

  log_destination_configs = [
    aws_cloudwatch_log_group.waf.arn
  ]
}
