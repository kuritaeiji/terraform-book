output "alb_dns_name" {
  value = aws_lb.backend_lb.dns_name
  description = "バックエンドのロードバランサーのDNS名"
}

output "asg_name" {
  value = aws_autoscaling_group.backend_asg.name
  description = "ASG名"
}

output "alb_security_group_id" {
  value = aws_security_group.backend.id
  description = "ロードバランサーのセキュリティーグループID"
}