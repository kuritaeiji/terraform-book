terraform {
  required_providers {
    aws = {
      source = "registry.terraform.io/hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix = "terraform-up-and-running"
  allocated_storage = 10
  instance_class = "db.t3.micro"
  skip_final_snapshot = true

  # バックアップ保持期間
  backup_retention_period = var.backup_retention_period

  # replicate_source_dbが指定されている場合はクロスリージョンレプリカ
  replicate_source_db = var.replicate_source_db

  # プライマリーインスタンスの場合のみ以下のパラメーターを設定する
  # クロスリージョンレプリカの場合は以下のパラメーターをnullに設定する
  engine = var.replicate_source_db == null ? "mysql" : null
  db_name = var.replicate_source_db == null ? "db" : null
  username = var.replicate_source_db == null ? var.db_username : null
  password = var.replicate_source_db == null ? var.db_password : null
}

