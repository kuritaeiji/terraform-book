terraform {
  required_providers {
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

locals {
  pod_labels = {
    app = var.name
  }
}

resource "kubernetes_deployment" "app" {
  metadata {
    name = var.name
  }

  spec {
    strategy {
      type = "RollingUpdate"
      rolling_update {
        max_unavailable = 1
      }
    }

    replicas = var.replicas

    selector {
      match_labels = local.pod_labels
    }

    template {
      metadata {
        labels = local.pod_labels
      }

      spec {
        container {
          name = var.name
          image = var.image

          port {
            container_port = var.container_port
          }

          dynamic "env" {
            for_each = var.environment_variables

            content {
              name = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name = var.name
  }

  spec {
    type = "LoadBalancer"

    selector = local.pod_labels

    port {
      name = "http"
      protocol = "TCP"
      port = 80
      target_port = var.container_port
    }
  }
}