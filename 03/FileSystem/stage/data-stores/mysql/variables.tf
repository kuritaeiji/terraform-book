variable "db_username" {
  type = string
  sensitive = true
  description = "DBのユーザー名"
}

variable "db_password" {
  type = string
  sensitive = true
  description = "DBのパスワード"
}