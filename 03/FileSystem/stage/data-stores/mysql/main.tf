terraform {
  backend "s3" {
    key = "stage/mysql/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  engine = "mysql"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  # DBが削除される際にスナップショットを作成しないよう設定する
  skip_final_snapshot = true
  db_name = "example_database"

  username = var.db_username
  password = var.db_password
}