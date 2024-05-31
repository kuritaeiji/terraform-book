provider "kubernetes" {
  config_path = "~/.kube/config"
  config_context = "kind-kind-cluster"
}

module "simple_webapp" {
  source = "../../modules/services/k8s-app"

  name = "simple-webapp"
  image = "training/webapp"
  replicas = 2
  container_port = 5000

  environment_variables = {
    PROVIDER = "Terraform"
  }
}