output "alb_dns_name" {
  value = module.alb.alb_dns_name
}

output "alb_security_group_id" {
  value = module.alb.alb_security_group_id
}

output "asg_name" {
  value = module.asg.asg_name
}

output "instance_security_group_id" {
  value = module.asg.instance_security_group_id
}