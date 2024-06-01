provider "aws" {
  region = "us-east-2"
  profile = "default"
}

module "hello_world_app" {
  source = "git@github.com:kuritaeiji/terraform-book.git///08/modules/services/hello-world?ref=v0.0.1"
  # source = "../../../../modules/services/hello-world"

  environment = "stage"
  min_size = 1
  max_size = 2
  enable_autoscaling = false
  ami = data.aws_ami.ubuntu.id
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


data "aws_ami" "ubuntu" {
  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}