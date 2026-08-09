output "alb_arn" {
  description = "Application Load Balancer ARN."
  value       = aws_lb.application.arn
}

output "alb_dns_name" {
  description = "Application Load Balancer DNS name."
  value       = aws_lb.application.dns_name
}

output "alb_zone_id" {
  description = "Application Load Balancer hosted zone ID."
  value       = aws_lb.application.zone_id
}

output "target_group_arn" {
  description = "Application target group ARN."
  value       = aws_lb_target_group.application.arn
}
