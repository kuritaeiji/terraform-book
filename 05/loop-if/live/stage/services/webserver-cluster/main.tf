terraform {
  backend "s3" {
    key = "stage/services/web-server-cluster/terraform.tfstate"
  }
}

provider "aws" {
  region = "us-east-2"
}

module "webserver-cluster" {
  source = "../../../../modules/services/webserver-cluster"

  server_text = "New server text"

  cluster_name = "webservers-stag"
  db_remote_state_bucket = "kuritaeiji-terraform-up-and-running-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2

  custom_tags = {
    Owner = "stage"
  }

  enable_autoscaling = false
}
