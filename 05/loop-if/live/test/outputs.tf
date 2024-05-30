output "firlst_user_arn" {
  value = aws_iam_user.user1[0].arn
  description = "最初のユーザーのARN"
}

output "neo_cloudwatch_policy_arn" {
  value = one(concat(aws_iam_policy_attachment.cloud_watch_full_access[*].policy_arn, aws_iam_policy_attachment.cloud_watch_read_only[*].policy_arn))
}

output "all_user_arn" {
  value = aws_iam_user.user1[*].arn
  description = "全ユーザーのARN配列"
}

output "module_all_user_arn" {
  value = module.users[*].user_arn
  description = "モジュールで作成した全ユーザーのARN"
}

output "for_each_all_user_arn" {
  value = values(aws_iam_user.user3)[*].arn
}

output "for_each_module_all_user_arn" {
  value = values(module.for_each_uesrs)[*].user_arn
}

output "uppercase_usernames" {
  value = [for name in var.user_names : upper(name)]
}

output "bios" {
  value = [for name, role in var.hero : "${name} is the ${role}"]
}

output "upper_roles" {
  value = {for name, role in var.hero : upper(name) => upper(role)}
}

output "for_directives" {
  value = "%{for name in var.user_names}${name}, %{endfor}"
}

output "for_directive_index" {
  value = "%{for i, name in var.user_names}(${i}) ${name}, %{endfor}"
}

output "for_directive_index_if" {
  value = <<EOF
%{~ for i, name in var.user_names ~}
${name}%{if i < length(var.user_names) - 1}, %{else}.%{endif}
%{~ endfor ~}
EOF
}