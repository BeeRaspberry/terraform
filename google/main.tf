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

# Create DNS zone, if domain name is provided.
resource "google_dns_managed_zone" "dns_zone" {
  count       = var.domain_name != "" ? 1 : 0
  name        = replace(var.domain_name, ".", "-")
  dns_name    = "${var.domain_name}."
}

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
  ]
}

module "vpc" {
  source  = "terraform-google-modules/network/google"
  version = "~> 2.3"

  project_id   = module.enabled_google_apis.project_id
  network_name = local.network_name
  routing_mode = "GLOBAL"

  subnets = [
    {
      subnet_name           = local.subnet_name
      subnet_ip             = var.subnet_ip
      subnet_region         = var.region
      subnet_private_access = true
      description           = "This subnet is managed by Terraform"
    }
  ]
  secondary_ranges = {
    "${local.subnet_name}" = [
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
  project_id    = module.enabled_google_apis.project_id
  region        = var.region
  router        = "${var.cluster_name}-router"
  network       = module.vpc.network_self_link
  create_router = true
}

data "template_file" "startup_script" {
  template = <<-EOF
  sudo apt-get update -y
  sudo apt-get install -y tinyproxy
  EOF
}

module "bastion" {
  source           = "terraform-google-modules/bastion-host/google"
  version          = "~> 2.0"
  network          = module.vpc.network_self_link
  subnet           = module.vpc.subnets_self_links[0]
  project          = module.enabled_google_apis.project_id
  host_project     = module.enabled_google_apis.project_id
  name             = local.bastion_name
  zone             = local.bastion_zone
  image_project    = "debian-cloud"
  image_family     = "debian-10"
  machine_type     = "g1-small"
  disk_size_gb     = 20
  startup_script   = data.template_file.startup_script.rendered
  members          = var.bastion_members
  shielded_vm      = "false"
}

module "gke" {
  source                     = "terraform-google-modules/kubernetes-engine/google//modules/safer-cluster-update-variant"
  project_id                 = module.enabled_google_apis.project_id
  name                       = var.cluster_name
  region                     = var.region
  regional                   = var.regional

  network                    = module.vpc.network_name
  network_project_id         = var.network_project_id
  kubernetes_version         = var.kubernetes_version 

  subnetwork                 = module.vpc.subnets_names[0]
  ip_range_pods              = module.vpc.subnets_secondary_ranges[0].*.range_name[0]
  ip_range_services          = module.vpc.subnets_secondary_ranges[0].*.range_name[1]
  
  master_authorized_networks = [{
    cidr_block   = "${module.bastion.ip_address}/32"
    display_name = "Bastion Host"
  }]

  horizontal_pod_autoscaling    = var.horizontal_pod_autoscaling
  http_load_balancing           = var.http_load_balancing
//  network_policy                = true
  maintenance_start_time        = var.maintenance_start_time

  initial_node_count            = var.initial_node_count
//  remove_default_node_pool      = true

  node_pools                    = var.node_pools
  node_pools_labels             = var.node_pools_labels
  node_pools_metadata           = var.node_pools_metadata
  node_pools_taints             = var.node_pools_taints
  node_pools_tags               = var.node_pools_tags

  node_pools_oauth_scopes       = var.node_pools_oauth_scopes
  stub_domains                  = {}
// Doesn't work... unable to execute kubectl commands once bastion proxy is required.
//  stub_domains               = var.domain_name != "" ? local.stub_domains : {}
  upstream_nameservers          = var.upstream_nameservers

  logging_service               = var.logging_service
  monitoring_service            = var.monitoring_service

//  create_service_account        = var.compute_engine_service_account == "" ? true : false
//  service_account               = var.compute_engine_service_account
  registry_project_id           = var.registry_project_id
  grant_registry_access         = true

//  issue_client_certificate      = false

  cluster_resource_labels       = var.cluster_resource_labels

  enable_private_endpoint       = false
//  deploy_using_private_endpoint = true

  // Private nodes better control public exposure, and reduce
  // the ability of nodes to reach to the Internet without
  // additional configurations.
//  enable_private_nodes          = true

  master_ipv4_cidr_block        = var.master_ipv4_cidr_block

  // Istio is recommended for pod-to-pod communications.
  istio                         = var.istio
  cloudrun                      = var.cloudrun

  default_max_pods_per_node     = var.default_max_pods_per_node

  database_encryption           = var.database_encryption

  // We suggest to define policies about  which images can run on a cluster.
//  enable_binary_authorization   = true

  // Define PodSecurityPolicies for different applications.
  // Example: https://kubernetes.io/docs/concepts/policy/pod-security-policy/#example
//  pod_security_policy_config    = var.pod_security_policy_config

  resource_usage_export_dataset_id = var.resource_usage_export_dataset_id

  // Sandbox is needed if the cluster is going to run any untrusted workload (e.g., user submitted code).
  // Sandbox can also provide increased protection in other cases, at some performance cost.
  sandbox_enabled = var.sandbox_enabled

  // Intranode Visibility enables you to capture flow logs for traffic between pods and create FW rules that apply to traffic between pods.
  enable_intranode_visibility = var.enable_intranode_visibility

  enable_vertical_pod_autoscaling = var.enable_vertical_pod_autoscaling

  // We enable identity namespace by default.
  //identity_namespace = "${var.project_id}.svc.id.goog"

  authenticator_security_group = var.authenticator_security_group

  enable_shielded_nodes = var.enable_shielded_nodes

  skip_provisioners = var.skip_provisioners
}

module "alerts" {
  source            = "./modules/alerts"
  notification_list = var.notification_list
}
