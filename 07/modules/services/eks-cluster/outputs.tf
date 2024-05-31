output "cluster_name" {
  value = aws_eks_cluster.cluster.name
}

output "cluster_arn" {
  value = aws_eks_cluster.cluster.arn
}

output "cluster_endpoint" {
  value = aws_eks_cluster.cluster.endpoint
}

output "cluster_certificate_authority" {
  value = aws_eks_cluster.cluster.certificate_authority
}