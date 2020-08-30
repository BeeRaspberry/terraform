resource "google_compute_network" "private_network" {
  provider = google-beta
  name     = "${var.cluster_name}-${var.environment}-private-network"
}

resource "google_compute_global_address" "private_ip_address" {
  provider      = google-beta
  name          = "${var.cluster_name}-${var.environment}private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  provider                = google-beta
  network                 = google_compute_network.private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "random_id" "db_name_suffix" {
  byte_length = 4
}

resource "google_sql_database_instance" "master" {
  count            = var.db_machine_type == "" ? 0 : 1
  name             = "${var.cluster_name}-${var.environment}-${random_id.db_name_suffix.hex}-db-instance"
  database_version = var.db_version
  region           = var.region

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = var.db_machine_type
    location_preference{
      zone = var.zone
    }
    ip_configuration {
      ipv4_enabled    = false
      private_network = google_compute_network.private_network.id
    }
  }
}

resource "google_sql_user" "api_user" {
  count            = var.db_machine_type == "" ? 0 : 1
  name     = "api"
  instance = google_sql_database_instance.master[count.index].name
  password = var.api_password
}