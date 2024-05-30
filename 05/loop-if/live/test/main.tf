provider "aws" {
  region = "us-east-2"
}

resource "aws_iam_user" "user1" {
  count = 3
  name = "neo.${count.index}"
}

resource "aws_iam_policy" "cloud_watch_readonly" {
  name = "cloud-watch-readonly"
  policy = data.aws_iam_policy_document.cloud_watch_read_only.json
}

data "aws_iam_policy_document" "cloud_watch_read_only" {
  statement {
    effect = "Allow"
    actions = [
      "cloudwatch:Describe*",
      "cloudwatch:Get*",
      "cloudwatch:List*"
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "cloud_watch_full_access" {
  name = "cloud-watch-full-access"
  policy = data.aws_iam_policy_document.cloud_watch_full_access.json
}

data "aws_iam_policy_document" "cloud_watch_full_access" {
  statement {
    effect = "Allow"
    actions = ["cloudwatch:*"]
    resources = ["*"]
  }
}

resource "aws_iam_policy_attachment" "cloud_watch_full_access" {
  count = var.give_neo_cloudwatch_full_access ? 1 : 0

  name = "cloud-watch-full-access"
  users = [aws_iam_user.user1[0].name]
  policy_arn = aws_iam_policy.cloud_watch_full_access.arn
}

resource "aws_iam_policy_attachment" "cloud_watch_read_only" {
  count = var.give_neo_cloudwatch_full_access ? 0 : 1

  name = "cloud-watch-read-only"
  users = [aws_iam_user.user1[0].name]
  policy_arn = aws_iam_policy.cloud_watch_readonly.arn
}

resource "aws_iam_user" "user2" {
  count = length(var.user_names)
  name = var.user_names[count.index]
}

module "users" {
  source = "../../modules/test"

  count = length(var.module_user_names)
  user_name = var.module_user_names[count.index]
}

resource "aws_iam_user" "user3" {
  for_each = toset(var.for_each_user_names)
  name = each.value
}

module "for_each_uesrs" {
  source = "../../modules/test"

  for_each = toset(var.for_each_module_user_names)
  user_name = each.value
}

resource "aws_security_group" "sg" {
  name = "sg"

  dynamic ingress {
    for_each = toset(var.web_server_ingress_rules)

    content {
      from_port = ingress.value.from_port
      to_port = ingress.value.to_port
      protocol = ingress.value.protocol
      cidr_blocks = ingress.value.cidr_blocks
    }
  }
}

