output "asg_name" {
  value = aws_autoscaling_group.app.name
}

output "instance_security_group_id" {
  value = aws_security_group.instance.id
}