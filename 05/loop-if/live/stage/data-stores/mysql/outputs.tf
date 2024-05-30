output "address" {
  value = module.mysql.address
  description = "DBのDNS名"
}

output "port" {
  value = module.mysql.port
  description = "DBのポート名"
}

