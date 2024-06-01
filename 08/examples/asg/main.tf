provider "aws" {
  region = "us-east-2"
  profile = "default"
}

module "asg" {
  source = "../../modules/cluster/asg-rolling-deploy"

  cluster_name = var.cluster_name
  ami = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"

  subnet_ids = data.aws_subnets.default.ids
  min_size = 1
  max_size = 2
  enable_autoscaling = false
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