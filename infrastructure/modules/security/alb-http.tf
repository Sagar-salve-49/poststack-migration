# Domain/ACM certificate is not available in this environment.
# HTTP is intentionally exposed on port 80 for the current deployment.
# HTTPS will be introduced when a domain and ACM certificate are provisioned.

#checkov:skip=CKV_AWS_260:HTTP on port 80 is intentionally public because this environment has no domain/ACM certificate.
resource "aws_vpc_security_group_ingress_rule" "alb_http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  ip_protocol = "tcp"
  to_port     = 80

  description = "Allow HTTP traffic to the application ALB."
}
