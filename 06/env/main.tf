provider "aws" {
  region = "us-east-2"
  profile = "default"
}

variable "db_username" {
  type = string
  sensitive = true
}

variable "db_password" {
  type = string
  sensitive = true
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  skip_final_snapshot = true
  db_name = "db"

  username = var.db_username
  password = var.db_password
}

