resource "aws_security_group" "alb" {
  #checkov:skip=CKV2_AWS_5:ALB security group is attached to the Application Load Balancer through module.alb.
  name        = "${var.project_name}-${var.environment}-alb"
  description = "Security group for the application Application Load Balancer."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-alb-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "alb_https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  ip_protocol = "tcp"
  to_port     = 443

  description = "Allow HTTPS traffic to the public ALB."
}

resource "aws_vpc_security_group_egress_rule" "alb_to_app" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = var.container_port
  ip_protocol                  = "tcp"
  to_port                      = var.container_port

  description = "Allow ALB to reach the application tasks."
}

resource "aws_security_group" "app" {
  #checkov:skip=CKV2_AWS_5:ECS application security group will be attached to ECS task ENIs in the ECS phase.
  name        = "${var.project_name}-${var.environment}-app"
  description = "Security group for application ECS tasks."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-app-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "app_from_alb" {
  security_group_id = aws_security_group.app.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = var.container_port
  ip_protocol                  = "tcp"
  to_port                      = var.container_port

  description = "Allow application traffic only from the ALB."
}

resource "aws_vpc_security_group_egress_rule" "app_to_vpc" {
  security_group_id = aws_security_group.app.id

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "-1"

  description = "Allow application tasks to communicate with VPC resources and VPC endpoints."
}

resource "aws_security_group" "vpc_endpoints" {
  name        = "${var.project_name}-${var.environment}-vpc-endpoints"
  description = "Security group for AWS interface VPC endpoints."
  vpc_id      = var.vpc_id

  tags = merge(local.common_tags, {
    Name = "${var.project_name}-${var.environment}-vpc-endpoints-sg"
  })
}

resource "aws_vpc_security_group_ingress_rule" "vpc_endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id

  referenced_security_group_id = aws_security_group.app.id
  from_port                    = 443
  ip_protocol                  = "tcp"
  to_port                      = 443

  description = "Allow ECS tasks to access AWS interface endpoints over HTTPS."
}

resource "aws_vpc_security_group_egress_rule" "vpc_endpoints_https" {
  security_group_id = aws_security_group.vpc_endpoints.id

  cidr_ipv4   = var.vpc_cidr
  ip_protocol = "-1"

  description = "Allow endpoint responses within the VPC."
}
