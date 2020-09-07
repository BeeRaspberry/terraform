/**
 * Copyright 2020 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
module "enabled_google_apis" {
  source  = "terraform-google-modules/project-factory/google//modules/project_services"
  version = "~> 8.0"

  project_id                  = var.project_id
  disable_services_on_destroy = false

  activate_apis = [
    "iam.googleapis.com",
    "compute.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "containerregistry.googleapis.com",
    "container.googleapis.com",
    "binaryauthorization.googleapis.com",
    "stackdriver.googleapis.com",
    "iap.googleapis.com",
    "secretmanager.googleapis.com",
    "sqladmin.googleapis.com",
    "servicenetworking.googleapis.com"
  ]
}

# Create DNS zone, if domain name is provided.
resource "google_dns_managed_zone" "dns_zone" {
  count    = var.domain_name != "" ? 1 : 0
  name     = replace(var.domain_name, ".", "-")
  dns_name = "${var.domain_name}."
}

# Create service account to manage DNS for letsencrypt
resource "google_service_account" "dns_solver" {
  count      = var.letsencrypt == true ? 1 : 0
  account_id = "dns-solver-${var.cluster_name}"
  project    = var.project_id
}

resource "google_project_iam_binding" "project" {
  count   = var.letsencrypt == true ? 1 : 0
  project = var.project_id
  role    = "roles/dns.admin"

  members = [
    "serviceAccount:${google_service_account.dns_solver[count.index].email}",
  ]
}

module "network" {
  source                  = "./modules/network"
  project_id              = var.project_id
  region                  = var.region
  cluster_name            = var.cluster_name
  subnet_ip               = var.subnet_ip
  ip_range_pods_name      = var.ip_range_pods_name
  ip_range_services_name  = var.ip_range_services_name
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

data "google_compute_zones" "available" {
  provider = google-beta
  project  = var.project_id
  region   = var.region
}

module "secrets" {
  db_count     = var.db_machine_type == "" ? 0 : 1
  source       = "./modules/secrets"
  cluster_name = var.cluster_name
  project_id   = var.project_id
  environment  = var.environment
  region       = var.region
}

module "database" {
  source              = "./modules/database"
  cluster_name        = var.cluster_name
  environment         = var.environment
  region              = var.region 
  db_version          = var.db_version
  db_machine_type     = var.db_machine_type 
  api_password        = module.secrets.api_password
  root_password       = module.secrets.root_password
  zone                = data.google_compute_zones.available.names[0]
  network             = module.network.db_network
  db_depends_on       = module.network.db_depends_on
}

module "bastion" {
  source         = "terraform-google-modules/bastion-host/google"
  version        = "~> 2.0"
  network        = module.network.bastion_network
  subnet         = module.network.bastion_subnet
  project        = module.enabled_google_apis.project_id
  host_project   = module.enabled_google_apis.project_id
  name           = local.bastion_name
  zone           = data.google_compute_zones.available.names[0]
  image_project  = "debian-cloud"
  image_family   = "debian-10"
  machine_type   = "g1-small"
  disk_size_gb   = 20
  startup_script = data.template_file.startup_script.rendered
  members        = var.bastion_members
  shielded_vm    = "false"
}

module "gke" {
  source     = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster"
  project_id = module.enabled_google_apis.project_id
  name       = var.cluster_name
  region     = var.region
  regional   = var.regional

  master_authorized_networks = [{
    cidr_block   = "${module.bastion.ip_address}/32"
    display_name = "Bastion Host"
  }]

  network                          = module.network.network_name
  network_project_id               = var.network_project_id
  kubernetes_version               = var.kubernetes_version
  subnetwork                       = module.network.subnetwork
  ip_range_pods                    = module.network.ip_range_pods
  ip_range_services                = module.network.ip_range_services
  horizontal_pod_autoscaling       = var.horizontal_pod_autoscaling
  http_load_balancing              = var.http_load_balancing
  maintenance_start_time           = var.maintenance_start_time
  initial_node_count               = var.initial_node_count
  node_pools                       = local.node_pools
  node_pools_labels                = var.node_pools_labels
  node_pools_metadata              = var.node_pools_metadata
  node_pools_taints                = var.node_pools_taints
  node_pools_tags                  = var.node_pools_tags
  enable_vertical_pod_autoscaling  = var.enable_vertical_pod_autoscaling
  authenticator_security_group     = var.authenticator_security_group
  enable_shielded_nodes            = var.enable_shielded_nodes
  skip_provisioners                = var.skip_provisioners
  node_pools_oauth_scopes          = var.node_pools_oauth_scopes
  upstream_nameservers             = var.upstream_nameservers
  logging_service                  = var.logging_service
  monitoring_service               = var.monitoring_service
  registry_project_id              = var.registry_project_id
  grant_registry_access            = true
  cluster_resource_labels          = var.cluster_resource_labels
  enable_private_endpoint          = var.enable_private_endpoint
  master_ipv4_cidr_block           = var.master_ipv4_cidr_block
  cloudrun                         = var.cloudrun
  default_max_pods_per_node        = var.default_max_pods_per_node
  database_encryption              = var.database_encryption
  resource_usage_export_dataset_id = var.resource_usage_export_dataset_id
  zones                            = var.regional == true ? data.google_compute_zones.available.names : [data.google_compute_zones.available.names[0]]

  // Istio is recommended for pod-to-pod communications.
  istio = var.istio

  // Define PodSecurityPolicies for different applications.
  // Example: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example
  //  pod_security_policy_config    = var.pod_security_policy_config


  // Sandbox is needed if the cluster is going to run any untrusted workload (e.g., user submitted code).
  // Sandbox can also provide increased protection in other cases, at some performance cost.
  sandbox_enabled = var.sandbox_enabled

  // Intranode Visibility enables you to capture flow logs for traffic between pods and create FW rules that apply to traffic between pods.
  enable_intranode_visibility = var.enable_intranode_visibility

  // Doesn't work... unable to execute kubectl commands once bastion proxy is required.
  //  stub_domains               = var.domain_name != "" ? local.stub_domains : {}
  stub_domains = {}

}

##module "alerts" {
##  source            = "./modules/alerts"
##  notification_list = var.notification_list
##}
#

# The following won't work as the cluster is private, requiring proxy through the Bastion
#resource "null_resource" "cert_manager" {
#  provisioner "local-exec" {
#    command = "kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.15.1/cert-manager.yaml"
#  }
#}
#
#resource "null_resource" "nginx_ingress" {
#  provisioner "local-exec" {
#    command = "helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx; helm repo update;helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx"
#  }
#}
#
#data "google_container_cluster" "cluster" {
#  name     = var.cluster_name
#  location = data.google_compute_zones.available.names[0]
#}
#
## Same parameters as kubernetes provider
#provider "kubernetes" {
#  load_config_file       = false
#  host                   = "https://${data.google_container_cluster.cluster.endpoint}"
#  token                  = "${data.google_container_cluster.cluster.access_token}"
#  cluster_ca_certificate = "${base64decode(data.google_container_cluster.cluster.master_auth.0.cluster_ca_certificate)}"
#}
#resource "kubectl_manifest" "install_cert_manager" {
#  yaml_body = file("${path.module}/my_service.yaml")
#}
#kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.16.1/cert-manager.yaml