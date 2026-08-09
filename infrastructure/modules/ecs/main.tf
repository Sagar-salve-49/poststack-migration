#checkov:skip=CKV_AWS_136:Existing ECR repository uses AES256 encryption. Migrating the existing repository to a customer-managed KMS key forces repository replacement and risks the existing application image. Repository migration will be handled separately.

resource "aws_ecr_repository" "app" {
  name                 = "${var.project_name}-${var.environment}-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecs.arn
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-ecr"
    Purpose = "ApplicationContainerImages"
  })
}

resource "aws_ecr_lifecycle_policy" "app" {
  repository = aws_ecr_repository.app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep the most recent 10 images"

        selection = {
          tagStatus   = "any"
          countType   = "imageCountMoreThan"
          countNumber = 10
        }

        action = {
          type = "expire"
        }
      }
    ]
  })
}

resource "aws_ecs_cluster" "app" {
  name = "${local.name_prefix}-ecs"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-ecs"
    Purpose = "ApplicationECSCluster"
  })
}

resource "aws_cloudwatch_log_group" "app" {
  name              = "/ecs/${local.name_prefix}-app"
  retention_in_days = 365
  kms_key_id        = aws_kms_key.ecs.arn

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-logs"
    Purpose = "ECSApplicationLogs"
  })
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${local.name_prefix}-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  # Keep the existing working ECS sizing.
  cpu    = "256"
  memory = "512"

  execution_role_arn = var.ecs_task_execution_role_arn
  task_role_arn      = var.ecs_task_role_arn

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${aws_ecr_repository.app.repository_url}:v1"
      essential = true

      portMappings = [
        {
          name          = "app"
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]

      healthCheck = {
        command = [
          "CMD-SHELL",
          "wget -q -O - http://127.0.0.1:${var.container_port}/health || exit 1"
        ]
        interval    = 30
        timeout     = 5
        retries     = 3
        startPeriod = 10
      }

      logConfiguration = {
        logDriver = "awslogs"

        options = {
          awslogs-group         = aws_cloudwatch_log_group.app.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-task"
    Purpose = "ECSApplicationTask"
  })
}

resource "aws_ecs_service" "app" {
  name            = "${local.name_prefix}-app"
  cluster         = aws_ecs_cluster.app.id
  task_definition = aws_ecs_task_definition.app.arn

  desired_count = 2
  launch_type   = "FARGATE"

  network_configuration {
    subnets = var.private_app_subnet_ids

    security_groups = [
      var.app_security_group_id
    ]

    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = var.container_port
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 50

  health_check_grace_period_seconds = 60

  tags = merge(local.common_tags, {
    Name    = "${local.name_prefix}-app-service"
    Purpose = "ECSApplicationService"
  })

  depends_on = [
    aws_cloudwatch_log_group.app
  ]
}
