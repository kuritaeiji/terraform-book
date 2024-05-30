provider "aws" {
  region = "us-east-2"
  profile = "default"
}

data "aws_secretsmanager_secret_version" "creds" {
  secret_id = "db_creds"
}

locals {
  db_creds = jsondecode(data.aws_secretsmanager_secret_version.creds.secret_string)
}

output "secrets" {
  sensitive = true
  value = "${local.db_creds.db_username}, ${local.db_creds.db_password}"
}