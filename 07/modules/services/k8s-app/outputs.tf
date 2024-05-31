output "service_endpoint" {
  value = try(
    kubernetes_service.app.status[0].load_balancer[0].ingress[0].hostname,
    "error parsing hostname from status"
  )
  description = "LBのホスト名"
}


