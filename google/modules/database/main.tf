resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  count            = var.db_machine_type == "" ? 0 : 1
  name             = "${var.cluster_name}-${var.environment}-${random_id.db_name_suffix.hex}-db-instance"
  database_version = var.db_version
  region = "us-central1"
  region           = var.region

  settings {
    tier = var.db_machine_type
    location_preference{
      zone = var.zone
    }
    ip_configuration {
      ipv4_enabled        = false
      private_network     = var.network
    }
  }
}

resource "google_sql_user" "root_user" {
  count    = var.db_machine_type == "" ? 0 : 1
  name     = "postgres"
  instance = google_sql_database_instance.master[count.index].name
  password = var.root_password
}

resource "google_sql_user" "api_user" {
  count    = var.db_machine_type == "" ? 0 : 1
  name     = "api"
  instance = google_sql_database_instance.master[count.index].name
  password = var.api_password
}