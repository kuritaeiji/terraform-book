provider "aws" {
  region = "us-east-2"
  profile = "default"
}

resource "aws_instance" "example" {
  ami = "ami-0fb653ca2d3203ac1"
  instance_type = "t2.micro"

  iam_instance_profile = aws_iam_instance_profile.instance.name
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "instance" {
  name_prefix = "instance"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "ec2_admin_permissions" {
  statement {
    effect = "Allow"
    actions = ["ec2:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "example" {
  role = aws_iam_role.instance.id
  policy = data.aws_iam_policy_document.ec2_admin_permissions.json
}

resource "aws_iam_instance_profile" "instance" {
  role = aws_iam_role.instance.name
}

// OIDC

// GitHubActionsのクライアント証明書
data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

// GitHubActionsをEC2やAWSアカウントのようにRoleを引き受ける対象としてAWSに登録する
resource "aws_iam_openid_connect_provider" "github_actions" {
  url = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assum_role_policy" {
  statement {
    effect = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
      type = "Federated"
    }

    condition {
      test = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        for github in var.allowed_repo_branches:
        "repo:${github["username"]}/${github["repo"]}:ref:refs/heads/${github["branch"]}"
      ]
    }
  }
}

resource "aws_iam_role" "example_role" {
  name_prefix = "example-role"
  assume_role_policy = data.aws_iam_policy_document.assum_role_policy.json
}

