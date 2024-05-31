variable "name" {
  type = string
  description = "EKSクラスター名"
}

variable "min_size" {
  type = number
  description = "ノードの最小台数"
}

variable "max_size" {
  type = number
  description = "ノードの最大台数"
}

variable "desired_size" {
  type = number
  description = "ノードの基本的な台数"
}

variable "instance_types" {
  type = list(string)
  description = "EC2インスタンスのタイプ（t3.microなど）"
}