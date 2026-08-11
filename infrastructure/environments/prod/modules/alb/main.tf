#checkov:skip=CKV2_AWS_76:WAFv2 WebACL with AWS managed Log4j protection is associated with this ALB through aws_wafv2_web_acl_association.application.

resource "aws_lb" "application" {
  name = substr(
    "${var.project_name}-${var.environment}-alb",
    0,
    32
  )

  internal           = false
  load_balancer_type = "application"

  security_groups = [
    var.alb_security_group_id
  ]

  subnets = var.public_subnet_ids

  # Required for production safety and Checkov CKV_AWS_150.
  enable_deletion_protection = true

  drop_invalid_header_fields = true

  access_logs {
    bucket  = aws_s3_bucket.alb_logs.id
    prefix  = "alb"
    enabled = true
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb"
  })
}

resource "aws_lb_target_group" "application" {
  #checkov:skip=CKV_AWS_378:Application traffic between the ALB and ECS tasks is HTTP inside the private VPC; TLS terminates at the ALB.

  name = substr(
    "${var.project_name}-${var.environment}-tg",
    0,
    32
  )

  port        = var.container_port
  protocol    = "HTTP"
  target_type = "ip"

  vpc_id = var.vpc_id

  deregistration_delay = 30

  health_check {
    enabled             = true
    healthy_threshold   = 2
    unhealthy_threshold = 3
    interval            = 30
    matcher             = "200-399"
    path                = "/"
    protocol            = "HTTP"
    timeout             = 5
  }

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-target-group"
  })
}

# Domain/ACM certificate is not available in this environment.
# HTTP is intentionally used for the current deployment.
# HTTPS and HTTP-to-HTTPS redirect will be introduced when a
# domain and ACM certificate are provisioned.

#checkov:skip=CKV_AWS_103:HTTPS is not configured because no domain/ACM certificate is available.
#checkov:skip=CKV2_AWS_20:HTTP-to-HTTPS redirect is not configured because no HTTPS listener/certificate is available.
#checkov:skip=CKV_AWS_2:HTTPS listener is intentionally not configured until a domain/ACM certificate is provisioned.
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.application.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.application.arn
  }

  tags = merge(local.common_tags, {
    Name    = "${var.project_name}-${var.environment}-alb-http-listener"
    Purpose = "ALBHTTPListener"
  })
}
