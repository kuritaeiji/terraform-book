terraform {
  backend "s3" {
    key = "stage/data-stores/mysql/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "mysql" {
  source = "../../../../modules/data-stores/mysql"
  db_username = var.db_username
  db_password = var.db_password
}