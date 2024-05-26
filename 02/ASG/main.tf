provider "aws" {
  region = "us-east-2"
}

variable "server_port" {
  description = "Webサーバーのポート番号"
  type = number
  default = 8080
}

output "alb_dns_name" {
  value = aws_lb.example.dns_name
  description = "AWS ALBのDNS名"
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

resource "aws_launch_configuration" "example" {
  image_id = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.instance.id]

  # パブリックIPアドレスを付与しない
  associate_public_ip_address = false

  user_data = <<-EOF
              #!/bin/bash
              echo 'Hello, World' > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF

  # ASGを使用する場合は必須
  # リソースを置き換える際に、新しいリソースを作成してから古いリソースを作成する
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier = data.aws_subnets.default.ids

  # どのLBのターゲットグループと結びつくか指定する
  target_group_arns = [aws_lb_target_group.asg.arn]
  # デフォルトのヘルスチェック方法はインスタンスの起動状況なのでELBによるヘルスチェックに変更する
  health_check_type = "ELB"

  min_size = 2
  max_size = 10

  tag {
    key = "Name"
    value = "terraform-asg-example"
    # 新しいインスタンスを起動するたびにこのタグをインスタンスに付与する設定
    propagate_at_launch = true
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    # from_port: 開放したい開始ポート番号
    # to_port: 開放したい終了ポート番号
    # 1~1024番を開放したい場合はfrom_port: 1, to_port: 1024にする
    from_port = var.server_port
    to_port = var.server_port
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb" "example" {
  name = "terraform-asg-example"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/html"
      message_body = "404: Page Not Found"
      status_code = 404
    }
  }
}

resource "aws_security_group" "alb" {
  name = "terraform-example-alb"

  ingress {
    from_port = 80
    to_port = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # アウトバウンドリクエストはすべて許可
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
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

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100

  condition {
    path_pattern {
      values = ["*"]
    }
  }

  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}
