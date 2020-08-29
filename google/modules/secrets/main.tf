resource "random_string" "db-root-pwd" {
  length           = 40
  special          = true
  override_special = "/@£$"
}

resource "google_secret_manager_secret" "db-root" {
  count     = var.db_count
  secret_id = "${var.cluster_name}-${var.environment}-db-root-password"

  labels = {
    name        = "db-root-password"
    environment = var.environment
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db-root-version" {
  count       = var.db_count
  secret      = google_secret_manager_secret.db-root.id
  secret_data = random_string.db-root-pwd.result
}

resource "random_string" "db-api-pwd" {
  length           = 40
  special          = true
  override_special = "/@£$"
}

resource "google_secret_manager_secret" "db-api" {
  count     = var.db_count
  secret_id = "${var.cluster_name}-${var.environment}-db-api-password"

  labels = {
    name        = "db-api-password"
    environment = var.environment
  }
  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
}

resource "google_secret_manager_secret_version" "db-api-version" {
  count       = var.db_count
  secret      = google_secret_manager_secret.db-api.id
  secret_data = random_string.db-api-pwd.result
}
