provider "aws" {
  region = "us-east-2"
  profile = "default"
}

module "eks_cluster" {
  source = "../../modules/services/eks-cluster"

  name = "example-eks-cluster"
  min_size = 1
  max_size = 2
  desired_size = 1

  # EKSが使用可能な最小インスタンスタイプはt3.small
  # t2.microなどはENIを4つしか持たないため、kube-proxyやkube-configなどしか起動できずPodを起動できない
  # 各ノードにENIが複数割り当てられPodはENIを使用する
  # つまりノードが192.168.1.0/24のサブネットに配置された場合、PodのIPアドレスは192.168.1.10などになる。
  instance_types = ["t3.small"]
}

provider "kubernetes" {
  host = module.eks_cluster.cluster_endpoint
  // クライアント証明書
  cluster_ca_certificate = base64decode(
    module.eks_cluster.cluster_certificate_authority[0].data
  )
  // Bearerトークン
  token = data.aws_eks_cluster_auth.cluster.token
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks_cluster.cluster_name
}

module "simple-webapp" {
  source = "../../modules/services/k8s-app"

  name = "simple-webapp"
  image = "training/webapp"
  replicas = 2
  container_port = 5000

  environment_variables = {
    PROVIDER = "Terraform"
  }

  depends_on = [ module.eks_cluster ]
}


