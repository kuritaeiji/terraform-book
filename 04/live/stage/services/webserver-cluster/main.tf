provider "aws" {
  region = "us-east-2"
}

module "webserver-cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name = "webservers-stag"
  db_remote_state_bucket = "kuritaeiji-terraform-up-and-running-state"
  db_remote_state_key = "stage/data-stores/mysql/terraform.tfstate"

  instance_type = "t2.micro"
  min_size = 2
  max_size = 2
}

resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
  autoscaling_group_name = module.webserver-cluster.asg_name

  scheduled_action_name = "scale-out-during-business-hours"
  min_size = 2
  max_size = 10
  desired_capacity = 10
  recurrence = "0 9 * * *"
}

resource "aws_autoscaling_schedule" "scale_in_at_night" {
  autoscaling_group_name = module.webserver-cluster.asg_name

  scheduled_action_name = "scale-in-at-night"
  min_size = 2
  max_size = 10
  desired_capacity = 2
  recurrence = "0 17 * * *"
}

resource "aws_security_group_rule" "allow_testing_ingress" {
  type = "ingress"
  security_group_id = module.webserver-cluster.alb_security_group_id

  from_port = 12345
  to_port = 12345
  protocol = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}