output "app_name" {
  value = kubernetes_deployment.bee-api-api.spec[0].template[0].metadata[0].labels.app
}
