resource "aws_cloudwatch_log_group" "ecs_app" {
  name              = "/ecs/${var.project_name}-${var.environment}-app"
  retention_in_days = 365
  kms_key_id        = "arn:aws:kms:ap-south-1:459640517515:key/6c0d67df-f38e-4b4e-823f-9a2ef0a129f1"

  tags = {
    Name    = "${var.project_name}-${var.environment}-app-logs"
    Purpose = "ECSApplicationLogs"
  }

  lifecycle {
    ignore_changes = [
      tags,
      tags_all
    ]
  }
}
