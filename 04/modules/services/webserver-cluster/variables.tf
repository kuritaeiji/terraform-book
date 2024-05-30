variable "server_port" {
  type = number
  description = "バックエンドサーバーのポート番号"
  default = 8080
}

variable "cluster_name" {
  type = string
  description = "Webサーバーのクラスター名"
}

variable "db_remote_state_bucket" {
  type = string
  description = "データベースリモートステートのS3バケット"
}

variable "db_remote_state_key" {
  type = string
  description = "データベースリモートステートのS3バケットオブジェクト名"
}

variable "instance_type" {
  type = string
  description = "EC2インスタンスのタイプ"
}

variable "min_size" {
  type = number
  description = "ASGのEC2インスタンスの最小台数"
}

variable "max_size" {
  type = number
  description = "ASGのEC2インスタンスの最大台数"
}
