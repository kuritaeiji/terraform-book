variable "cluster_name" {
  type = string
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
  validation {
    condition = contains(["t2.micro", "t3.micro"], var.instance_type)
    error_message = "無料枠のt2.micro,t3.microしか使用できません"
  }
}

variable "server_port" {
  type = number
  default = 8080
}

variable "user_data" {
  type = string
  default = null
}

variable "subnet_ids" {
  type = list(string)
}

variable "associate_public_ip_address" {
  type = bool
  default = true
}

variable "target_group_arns" {
  type = list(string)
  default = []
}

variable "health_chek_type" {
  type = string
  default = "EC2"
}

variable "min_size" {
  type = number
  validation {
    condition = var.min_size >= 0
    error_message = "ASGの最小台数は1台以上"
  }

  validation {
    condition = var.min_size <= 10
    error_message = "ASGの最小台数は10台以下"
  }
}

variable "max_size" {
  type = number
}

variable "custom_tags" {
  type = map(string)
  default = {}
}

variable "enable_autoscaling" {
  type = bool
}