output "address" {
  value = aws_db_instance.example.address
  description = "DBインスタンスのIPアドレス"
}

output "port" {
  value = aws_db_instance.example.port
  description = "DBインスタンスのポート番号"
}