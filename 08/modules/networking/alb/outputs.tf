output "alb_dns_name" {
  value = aws_lb.http.dns_name
}

output "alb_http_listener_arn" {
  value = aws_lb_listener.http.arn
}

output "alb_security_group_id" {
  value = aws_security_group.alb.id
}