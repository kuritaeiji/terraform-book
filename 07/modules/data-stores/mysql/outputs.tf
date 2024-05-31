output "arn" {
  value = aws_db_instance.example.arn
  description = "作成したDBインスタンスのARN"
}

output "address" {
  value = aws_db_instance.example.address
  description = "DBインスタンスのIPアドレス"
}

output "port" {
  value = aws_db_instance.example.port
  description = "DBインスタンスのポート番号"
}