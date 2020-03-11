provider "kubernetes" {}

data "vault_generic_secret" "bee_api" {
  path = "secret/bee_api"
}

resource "kubernetes_namespace" "a_namespace" {
  metadata {
    name = var.namespace
    labels = {
      environment = var.environment
    }
  }
}

resource "kubernetes_persistent_volume" "bee_api_volume" {
  metadata {
    name = "bee-api-pv-volume"
    labels = {
      type = "local"
    }
  }
  spec {
    access_modes = ["ReadWriteMany"]
    storage_class_name = "standard"
    capacity = {
      storage = "10Gi"
    }
    persistent_volume_source {
      host_path {
        path = "/mnt/data"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "bee_api_volume_claim" {
  metadata {
    name = "bee-api-pv-claim"
    namespace = kubernetes_namespace.a_namespace.metadata[0].name
    labels = {
      type = "local"
    }
  }
  spec {
    storage_class_name = "standard"
    access_modes = ["ReadWriteMany"]
    resources {
      requests = {
        storage = "3Gi"
      }
    }
  }
}

resource "kubernetes_config_map" "bee_api_configmap" {
  metadata {
    name = "bee-api-config"
    namespace = kubernetes_namespace.a_namespace.metadata[0].name
  }

  data = {
    DATABASE_DIR = "/app/data"
    DATABASE_USER = "bee_api"
  }
}

resource "kubernetes_secret" "bee_api_secrets" {
  metadata {
    name = "bee-api-secrets"
    namespace = kubernetes_namespace.a_namespace.metadata[0].name
  }

  data = {
    DATABASE_USER = data.vault_generic_secret.bee_api.data["DATABASE_USER"]
    DATABASE_PASSWORD = data.vault_generic_secret.bee_api.data["DATABASE_PASSWORD"]
    DATABASE_PORT = data.vault_generic_secret.bee_api.data["DATABASE_PORT"]
    DATABASE_HOST = data.vault_generic_secret.bee_api.data["DATABASE_HOST"]
  }
}
