module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3"

  project_id   = var.project_id
  network_name = "${var.cluster_name}-network"
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = "${var.cluster_name}-subnet"
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = true
      description           = "This subnet is managed by Terraform"
    }
  ]
  secondary_ranges = {
    "${var.cluster_name}-subnet" = [
      {
        range_name    = var.ip_range_pods_name
        ip_cidr_range = "192.168.0.0/18"
      },
      {
        range_name    = var.ip_range_services_name
        ip_cidr_range = "192.168.64.0/18"
      },
    ]
  }
}

module "cloud-nat" {
  source        = "terraform-google-modules/cloud-nat/google"
  version       = "~> 1.2"
  project_id    = var.project_id
  region        = var.region
  router        = "${var.cluster_name}-router"
  network       = module.vpc.network_self_link
  create_router = true
}

resource "google_compute_global_address" "private_ip_alloc" {
  name          = "${var.cluster_name}=private-ip-alloc"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = module.vpc.network_name
}

resource "google_service_networking_connection" "peering_connection" {
  network                 = module.vpc.network_self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_alloc.name]
}