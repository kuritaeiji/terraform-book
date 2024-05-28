terraform {
  backend "s3" {
    key = "stage/services/backend/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = "kuritaeiji-terraform-up-and-running-state"
    key = "stage/mysql/terraform.tfstate"
    region = "us-east-2"
  }
}

resource "aws_launch_configuration" "backend_lc" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [ aws_security_group.backend_sg.id ]

  associate_public_ip_address = false

  user_data = templatefile("user-data.sh", {
    server_port = var.server_port
    db_address = data.terraform_remote_state.db.outputs.address
    db_port = data.terraform_remote_state.db.outputs.port
  })

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_security_group" "backend_sg" {
  name = "backend_sg"

  ingress {
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_autoscaling_group" "backend_asg" {
  name = "backend-asg"

  launch_configuration = aws_launch_configuration.backend_lc.id
  vpc_zone_identifier = data.aws_subnets.default.ids

  min_size = 2
  max_size = 2
  desired_capacity = 2

  target_group_arns = [aws_lb_target_group.backend.arn]
  health_check_type = "ELB"

  tag {
    key = "Name"
    value = "backend-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_lb" "backend_lb" {
  name = "aws-lb"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.backend.id]
}

resource "aws_security_group" "backend" {
  name = "backend-lb-sg"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_listener" "backend" {
  load_balancer_arn = aws_lb.backend_lb.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      status_code = 404
      content_type = "text/html"
      message_body = "404: Page Not Found"
    }
  }
}

resource "aws_lb_target_group" "backend" {
  name = "backend-target-group"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "backend" {
  listener_arn = aws_lb_listener.backend.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }
}

