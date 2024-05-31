provider "aws" {
  region = "us-east-2"
  profile = "default"
  alias = "root"
}

provider "aws" {
  region = "us-east-2"
  alias = "stage"

  assume_role {
    role_arn = "arn:aws:iam::058264294856:role/OrganizationAccountAccessRole"
  }
}

module "multi_account_example" {
  source = "../../modules/multi-account"

  providers = {
    aws.parent = aws.root
    aws.child = aws.stage
  }
}

output "aws_root_account_id" {
  value = module.multi_account_example.parent_account_id
}

output "aws_stage_account_id" {
  value = module.multi_account_example.child_account_id
}