data "google_compute_zones" "available" {
  provider = google-beta
  project = var.project_id
  region  = var.region
}

output "cred_check" {
  value = data.google_compute_zones.available
}
