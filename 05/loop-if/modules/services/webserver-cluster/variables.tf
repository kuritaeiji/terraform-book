variable "server_port" {
  type = number
  description = "バックエンドサーバーのポート番号"
  default = 8080
}

variable "cluster_name" {
  type = string
  description = "Webサーバーのクラスター名"
}

variable "custom_tags" {
  type = map(string)
  description = "EC2インスタンスに付与するカスタムタグ"
}

variable "ami" {
  description = "EC2インスタンスのAMI"
  type = string
  default = "ami-0fb653ca2d3203ac1"
}

variable "server_text" {
  description = "webサーバーが返却するテキスト"
  type = string
  default = "Hello, World"
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

variable "enable_autoscaling" {
  type = bool
  description = "trueにするとオートスケールを有効にする"
}
