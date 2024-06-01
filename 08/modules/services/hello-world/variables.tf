variable "environment" {
  type = string
  description = "staging環境など"
}

variable "min_size" {
  type = number
}

variable "max_size" {
  type = number
}

variable "enable_autoscaling" {
  type = bool
}

variable "ami" {
  type = string
}

variable "instance_type" {
  type = string
  default = "t2.micro"
}

variable "server_text" {
  type = string
  default = "Hello, World"
}

variable "server_port" {
  type = number
  default = 8080
}

variable "custom_tags" {
  type = map(string)
  default = {}
}