variable "name" {
  type = string
  description = "このモジュールで作成するKubernetesリソースに付与する名前"
}

variable "image" {
  type = string
  description = "Dockerイメージ名"
}

variable "container_port" {
  type = number
  description = "コンテナがリッスンするポート番号"
}

variable "replicas" {
  type = number
  description = "レプリカ数"
}

variable "environment_variables" {
  type = map(string)
  description = "コンテナに設定する環境変数"
  default = {}
}