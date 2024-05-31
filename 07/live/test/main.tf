terraform {
  required_providers {
    aws = {
      source = "registry.terraform.io/hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-2"
  profile = "default"
  alias = "region_1"
}

provider "aws" {
  region = "us-west-1"
  profile = "default"
  alias = "region_2"
}

# data "aws_region" "region_1" {
#   provider = aws.region_1
# }

# data "aws_region" "region_2" {
#   provider = aws.region_2
# }

data "aws_ami" "ubuntu_region_1" {
  provider = aws.region_1

  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

data "aws_ami" "ubuntu_region_2" {
  provider = aws.region_2

  most_recent = true
  owners = ["099720109477"]

  filter {
    name = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "region_1" {
  provider = aws.region_1

  ami = data.aws_ami.ubuntu_region_1.id
  instance_type = "t2.micro"
}

resource "aws_instance" "region_2" {
  provider = aws.region_2

  ami = data.aws_ami.ubuntu_region_2.id
  instance_type = "t2.micro"
}

output "instance_region_1_az" {
  value = aws_instance.region_1.availability_zone
}

output "instance_region_2_az" {
  value = aws_instance.region_2.availability_zone
}
