variable "db_username" {
  description = "DBユーザー名"
  type = string
  sensitive = true
}

variable "db_password" {
  description = "DBパスワード"
  type = string
  sensitive = true
}