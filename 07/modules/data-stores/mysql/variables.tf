variable "db_username" {
  type = string
  sensitive = true
  default = null
}

variable "db_password" {
  type = string
  sensitive = true
  default = null
}

variable "db_name" {
  type = string
  default = null
}

variable "backup_retention_period" {
  type = number
  default = null
  description = "バックアップ保持日数。0より大きくするとクロスリージョンバックアップする。"
}

variable "replicate_source_db" {
  type = string
  default = null
  description = "レプリケーションする場合はRDSのARNを指定する"
}