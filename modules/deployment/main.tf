provider "kubernetes" {}

resource "kubernetes_deployment" "bee-api-api" {
  metadata {
    name = "bee-api-api"
    labels = {
      app         = "bee-api-api"
      environment = var.environment
    }
    namespace = var.namespace
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "bee-api-api"
      }
    }
    template {
      metadata {
        labels = {
          app = "bee-api-api"
        }
      }
      spec {
        container {
          image             = "bee-api:1.2"
          name              = "bee-api-api"
          image_pull_policy = "Never"

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

          volume_mount {
            mount_path = "/app/data"
            name       = "sqlite-volume"
          }

          env {
            name = "DATABASE_DIR"
            value_from {
              config_map_key_ref {
                name = "bee-api-config"
                key  = "DATABASE_DIR"
              }
            }
          }

          env {
            name = "DATABASE_USER"
            value_from {
              secret_key_ref {
                name = "bee-api-secrets"
                key  = "DATABASE_USER"
              }
            }
          }

          env {
            name = "DATABASE_PASSWORD"
            value_from {
              secret_key_ref {
                name = "bee-api-secrets"
                key  = "DATABASE_PASSWORD"
              }
            }
          }

          env {
            name = "DATABASE_HOST"
            value_from {
              secret_key_ref {
                name = "bee-api-secrets"
                key  = "DATABASE_HOST"
              }
            }
          }

          env {
            name = "DATABASE_PORT"
            value_from {
              secret_key_ref {
                name = "bee-api-secrets"
                key  = "DATABASE_PORT"
              }
            }
          }
        }

        volume {
          name = "sqlite-volume"
          persistent_volume_claim {
            claim_name = "bee-api-pv-claim"
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "bee-api-terraform-service" {
  metadata {
    name = "bee-api-terraform-service"
    labels = {
      app         = "bee-api-terraform-service"
      environment = var.environment
    }
    namespace = var.namespace
  }
  spec {
    selector = {
      app = kubernetes_deployment.bee-api-api.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port = 5000
    }

    type = "LoadBalancer"
  }
}

#output "lb_ip" {
#  value = kubernetes_service.bee-api-terraform-service.load_balancer_ingress[0].ip
#}

#output "lb_hostname" {
#  value = kubernetes_service.bee-api-terraform-service.load_balancer_ingress[0].hostname
#}
