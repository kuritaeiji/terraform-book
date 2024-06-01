terraform {
  required_version = ">= 1.0.0, < 2.0.0"

  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

locals {
  tcp_protocol = "tcp"
  all_ips = ["0.0.0.0/0"]
}

resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

resource "aws_security_group_rule" "allow_server_http_inbound" {
  security_group_id = aws_security_group.instance.id
  type = "ingress"

  from_port = var.server_port
  to_port = var.server_port
  protocol = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_launch_configuration" "app" {
  image_id = var.ami
  instance_type = var.instance_type

  security_groups = [aws_security_group.instance.id]
  associate_public_ip_address = var.associate_public_ip_address

  user_data = var.user_data

  lifecycle {
    create_before_destroy = true
    precondition {
      condition = data.aws_ec2_instance_type.instance.free_tier_eligible
      error_message = "${var.instance_type}は無料利用枠ではないので使用できません"
    }
  }
}

data "aws_ec2_instance_type" "instance" {
  instance_type = var.instance_type
}

resource "aws_autoscaling_group" "app" {
  name = var.cluster_name
  launch_configuration = aws_launch_configuration.app.name

  vpc_zone_identifier = var.subnet_ids

  target_group_arns = var.target_group_arns
  health_check_type = var.health_chek_type

  min_size = var.min_size
  max_size = var.max_size

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
  }

  tag {
    key = "Name"
    value = var.cluster_name
    propagate_at_launch = true
  }

  dynamic "tag" {
    for_each = var.custom_tags

    content {
      key = tag.key
      value = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    postcondition {
      condition = length(self.availability_zones) > 1
      error_message = "EC2インスタンスが1つのみのAZに配置されています"
    }
  }
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  count = var.enable_autoscaling ? 1 :0

  autoscaling_group_name = aws_autoscaling_group.app.name
  scheduled_action_name = "${var.cluster_name}-scale-out-during-business-hours"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.max_size
  recurrence = "0 17 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  count = var.enable_autoscaling ? 1 : 0

  autoscaling_group_name = aws_autoscaling_group.app.name
  scheduled_action_name = "${var.cluster_name}-scale-out-during-business-hours"
  min_size = var.min_size
  max_size = var.max_size
  desired_capacity = var.max_size
  recurrence = "0 17 * * *"
}

resource "aws_cloudwatch_metric_alarm" "heigh_cup_utilization" {
  alarm_name = "${var.cluster_name}-high-cpu-utilization"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  comparison_operator = "GreaterThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Average"
  threshold = 90
  unit = "Percent"
}

resource "aws_cloudwatch_metric_alarm" "low_cup_credit_balance" {
  count = format("%.1s", var.instance_type) == "t" ? 1 : 0

  alarm_name = "${var.cluster_name}-low-cpu-credit-balance"
  namespace = "AWS/EC2"
  metric_name = "CPUUtilization"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.app.name
  }

  comparison_operator = "LessThanThreshold"
  evaluation_periods = 1
  period = 300
  statistic = "Minimum"
  threshold = 10
  unit = "Count"
}