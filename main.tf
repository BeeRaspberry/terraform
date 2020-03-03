provider "kubernetes" {}

resource "kubernetes_deployment" "bee-api-terraform" {
  metadata {
    name = "bee-api-terraform"
    labels = {
      App = "bee-api-terraform"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "bee-api-terraform"
      }
    }
    template {
      metadata {
        labels = {
          App = "bee-api-terraform"
        }
      }
      spec {
        container {
          image = "bee-api:1.0"
          name  = "bee-api-terraform"

          port {
            container_port = 5000
          }

          resources {
            limits {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bee-api-terraform-service" {
  metadata {
    name = "bee-api-terraform-service"
  }
  spec {
    selector = {
      app = "${kubernetes_deployment.bee-api-terraform.spec.0.template.0.metadata.0.labels.app}"

    }
    port {
      port        = 5000
      target_port = 5000
    }

    type = "LoadBalancer"
  }
}

output "lb_ip" {
  value = kubernetes_service.bee-api-terraform-service.load_balancer_ingress[0].ip
}

output "lb_hostname" {
  value = kubernetes_service.bee-api-terraform-service.load_balancer_ingress[0].hostname
}
