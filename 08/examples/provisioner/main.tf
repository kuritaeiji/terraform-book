terraform {
  required_version = "~> 1.0"
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "default"
}

resource "aws_security_group" "instance" {
  name = "instance"

  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "tls_private_key" "instance" {
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "aws_key_pair" "generated_key" {
  public_key = tls_private_key.instance.public_key_openssh
}

resource "aws_instance" "instance" {
  instance_type = "t2.micro"
  ami = data.aws_ami.ubuntu.id
  vpc_security_group_ids = [aws_security_group.instance.id]
  key_name = aws_key_pair.generated_key.key_name

  tags = {
    Name = "ssh-instance"
  }

  provisioner "remote-exec" {
    inline = [ "echo \"Hello, World from $(uname)\"" ]
  }

  connection {
    type = "ssh"
    host = self.public_ip
    user = "ubuntu"
    private_key = tls_private_key.instance.private_key_pem
  }
}

resource "null_resource" "local_exec" {
  // terraform applyスルたびにlocal-execを実行するためにuuidを付与する
  triggers = {
    uuid = uuid()
  }

  provisioner "local-exec" {
    command = "uname"
  }
}