provider "aws" {
  region = "us-east-2"
  profile = "default"
}

# defaultプロファイルのIAMユーザー
data "aws_caller_identity" "self" {}

data "aws_iam_policy_document" "cmk_admin_policy" {
  statement {
    effect = "Allow"
    actions = ["kms:*"]
    resources = ["*"]
    principals {
      type = "AWS"
      identifiers = [data.aws_caller_identity.self.arn]
    }
  }
}

resource "aws_kms_key" "cmk" {
  // cmkを使用可能なのはprofile=defaultのIAMユーザーのみ
  policy = data.aws_iam_policy_document.cmk_admin_policy.json
}

resource "aws_kms_alias" "cmk" {
  name = "alias/kms-cmk-example"
  target_key_id = aws_kms_key.cmk.id
}

data "aws_kms_secrets" "creds" {
  secret {
    name = "db"
    payload = file("${path.module}/db-creds.yaml.encrypted")
  }
}

locals {
  db_creds = yamldecode(data.aws_kms_secrets.creds.plaintext["db"])
}

output "db_creds" {
  value = "username: ${local.db_creds.db_username}, password: ${local.db_creds.db_password}"
  sensitive = true
}
