terraform {
  backend "s3" {
    key = "global/S3/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

output "dynamodb_table_name" {
  value = aws_dynamodb_table.terraform_lock.name
  description = "DynamoDBテーブル名"
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "kuritaeiji-terraform-up-and-running-state"

  lifecycle {
    prevent_destroy = true
  }
}

resource "aws_s3_bucket_versioning" "enabled" {
  bucket = aws_s3_bucket.terraform_state.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "default" {
  bucket = aws_s3_bucket.terraform_state.id

  rule {
    # サーバーサイド暗号化のデフォルト設定を適用する
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.terraform_state.id

  # バケットに新しいパブリックACL（アクセス制御リスト）を付与することを防ぐ
  block_public_acls = true
  # バケットに新しいパブリックアクセスポリシーを付与することを防ぐ
  block_public_policy = true
  # バケットおよびバケット内のオブジェクトに設定されているパブリックACLによって付与されたアクセス権限を無視する
  ignore_public_acls = true
  # パブリックアクセスポリシーまたはACLによってパブリックアクセスが許可されているバケットに対して、そのパブリックアクセスを制限する
  restrict_public_buckets = true
}

resource "aws_dynamodb_table" "terraform_lock" {
  name = "terraform-up-and-running-locks"
  billing_mode = "PAY_PER_REQUEST"
  hash_key = "LockID"

  attribute {
    name = "LockID"
    type = "S"
  }
}

