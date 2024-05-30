variable "user_names" {
  type = list(string)
  description = "IAMユーザーの名前配列"
  default = [ "neo", "trinity", "morpheus" ]
}

variable "give_neo_cloudwatch_full_access" {
  type = bool
  description = "trueの場合neoにCloudWatchへのFullAccess権限を付与。falseの場合ReadOnly権限を付与。"
  default = true
}

variable "module_user_names" {
  type = list(string)
  description = "モジュールで作成するIAMユーザー名の配列"
  default = [ "a", "aa", "aaa"]
}

variable "for_each_user_names" {
  type = list(string)
  default = [ "b", "bbb" ]
}

variable "for_each_module_user_names" {
  type = list(string)
  default = [ "c", "cc", "ccc" ]
}

variable "web_server_ingress_rules" {
  type = list(object({
    from_port = number
    to_port = number
    protocol = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {

      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "hero" {
  type = map(string)
  default = {
    "neo" = "hero"
    "trinity" = "love interset"
  }
}