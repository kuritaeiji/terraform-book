provider "aws" {
  region = "us-east-2"
  profile = "default"
  alias = "primary"
}

provider "aws" {
  region = "us-west-1"
  profile = "default"
  alias = "replica"
}

module "mysql_primary" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws.primary
  }

  db_username = var.db_username
  db_password = var.db_password
  db_name = "db"

  # レプリケーションをサポートするために必要
  backup_retention_period = 1
}

module "mysql_cross_region_replica" {
  source = "../../../../modules/data-stores/mysql"

  providers = {
    aws = aws.replica
  }

  replicate_source_db = module.mysql_primary.arn
}