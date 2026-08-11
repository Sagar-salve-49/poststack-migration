resource "aws_security_group" "lambda" {
  name        = "${var.project_name}-${var.environment}-lambda"
  description = "Security group for UAT Lambda."
  vpc_id      = var.vpc_id

  egress {
    description = "Allow Lambda outbound VPC traffic."
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-sg"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_cloudwatch_log_group" "lambda" {
  name              = "/aws/lambda/${var.project_name}-${var.environment}-function"
  retention_in_days = 7

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda-logs"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}

resource "aws_lambda_function" "app" {
  function_name = "${var.project_name}-${var.environment}-function"

  role    = aws_iam_role.lambda.arn
  runtime = "python3.12"
  handler = "index.handler"

  filename         = "${path.module}/lambda.zip"
  source_code_hash = filebase64sha256("${path.module}/lambda.zip")

  timeout     = 30
  memory_size = 128

  vpc_config {
    subnet_ids         = var.private_subnet_ids
    security_group_ids = [aws_security_group.lambda.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic,
    aws_iam_role_policy_attachment.lambda_vpc,
    aws_cloudwatch_log_group.lambda
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-lambda"
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
