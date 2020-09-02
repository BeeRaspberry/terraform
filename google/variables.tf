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

variable "cred_file" {
  description = "full path of credential.json, when used."
  default     = ""
}

variable "credential" {
  description = "credential.json stored in a variable. Takes precendence over cred_file"
  default     = ""
}

variable "project_id" {
  description = "The project ID to host the cluster in"
}

variable "environment" {
  default = "development"
}

variable "cluster_name" {
  description = "The name of the cluster"
  default     = "my-cluster"
}

variable "domain_name" {
  description = "Domain name used in the cluster."
  default     = ""
}

variable "region" {
  description = "The region to host the cluster in"
  default     = "us-east1"
}

variable "subnet_ip" {
  description = "The cidr range of the subnet"
  default     = "10.10.10.0/24"
}

variable "regional" {
  type        = bool
  description = "Whether is a regional cluster (zonal cluster if set false. WARNING: changing this after cluster creation is destructive!)"
  default     = true
}

variable "network_project_id" {
  description = "The project ID of the shared VPC's host (for shared vpc support)"
  default     = ""
}

variable "ip_range_pods_name" {
  description = "The secondary ip range to use for pods"
  default     = "ip-range-pods"
}

variable "ip_range_services_name" {
  description = "The secondary ip range to use for services"
  default     = "ip-range-services"
}

variable "kubernetes_version" {
  description = "The Kubernetes version of the masters. If set to 'latest' it will pull latest available version in the selected region. The module enforces certain minimum versions to ensure that specific features are available. "
  default     = "latest"
}

variable "node_version" {
  description = "The Kubernetes version of the node pools. Defaults kubernetes_version (master) variable and can be overridden for individual node pools by setting the `version` key on them. Must be empyty or set the same as master at cluster creation."
  default     = ""
}

variable "master_authorized_networks" {
  type        = list(object({ cidr_block = string, display_name = string }))
  description = "List of master authorized networks. If none are provided, disallow external access (except the cluster node IPs, which GKE automatically whitelists)."
  default     = []
}

variable "horizontal_pod_autoscaling" {
  type        = bool
  description = "Enable horizontal pod autoscaling addon"
  default     = true
}

variable "http_load_balancing" {
  type        = bool
  description = "Enable httpload balancer addon. The addon allows whomever can create Ingress objects to expose an application to a public IP. Network policies or Gatekeeper policies should be used to verify that only authorized applications are exposed."
  default     = true
}

variable "maintenance_start_time" {
  type        = string
  description = "Time window specified for daily maintenance operations in RFC3339 format"
  default     = "05:00"
}

variable "initial_node_count" {
  type        = number
  description = "The number of nodes to create in this cluster's default node pool."
  default     = 0
}

variable "bastion_members" {
  type        = list(string)
  description = "List of users, groups, SAs who need access to the bastion host"
  default     = []
}

variable "ip_source_ranges_ssh" {
  type        = list(string)
  description = "Additional source ranges to allow for ssh to bastion host. 35.235.240.0/20 allowed by default for IAP tunnel."
  default     = []
}

variable "node_min_count" {
  default = 1
}

variable "node_max_count" {
  default = 1
}

variable "node_machine_type" {
  default = "n2-standard-2"
}

variable "node_preemptible" {
  default = true
}

variable "node_auto_upgrade" {
  default = true
}

variable "node_pools_labels" {
  type        = map(map(string))
  description = "Map of maps containing node labels by node-pool name"

  default = {
    all               = {}
    default-node-pool = {}
  }
}

variable "node_pools_metadata" {
  type        = map(map(string))
  description = "Map of maps containing node metadata by node-pool name"

  default = {
    all               = {}
    default-node-pool = {}
  }
}

variable "node_pools_taints" {
  type        = map(list(object({ key = string, value = string, effect = string })))
  description = "Map of lists containing node taints by node-pool name"

  default = {
    all               = []
    default-node-pool = []
  }
}

variable "node_pools_tags" {
  type        = map(list(string))
  description = "Map of lists containing node network tags by node-pool name"

  default = {
    all               = []
    default-node-pool = []
  }
}

variable "node_pools_oauth_scopes" {
  type        = map(list(string))
  description = "Map of lists containing node oauth scopes by node-pool name"

  default = {
    all               = ["https://www.googleapis.com/auth/cloud-platform"]
    default-node-pool = []
  }
}


variable "upstream_nameservers" {
  type        = list(string)
  description = "If specified, the values replace the nameservers taken by default from the node’s /etc/resolv.conf"
  default     = []
}

variable "logging_service" {
  type        = string
  description = "The logging service that the cluster should write logs to. Available options include logging.googleapis.com, logging.googleapis.com/kubernetes (beta), and none"
  default     = "logging.googleapis.com/kubernetes"
}

variable "monitoring_service" {
  type        = string
  description = "The monitoring service that the cluster should write metrics to. Automatically send metrics from pods in the cluster to the Google Cloud Monitoring API. VM metrics will be collected by Google Compute Engine regardless of this setting Available options include monitoring.googleapis.com, monitoring.googleapis.com/kubernetes (beta) and none"
  default     = "monitoring.googleapis.com/kubernetes"
}

variable "grant_registry_access" {
  type        = bool
  description = "Grants created cluster-specific service account storage.objectViewer role."
  default     = false
}

variable "registry_project_id" {
  type        = string
  description = "Project holding the Google Container Registry. If empty, we use the cluster project. If grant_registry_access is true, storage.objectViewer role is assigned on this project."
  default     = ""
}

variable "service_account" {
  type        = string
  description = "The service account to run nodes as if not overridden in `node_pools`. The create_service_account variable default value (true) will cause a cluster-specific service account to be created."
  default     = ""
}

variable "cluster_resource_labels" {
  type        = map(string)
  description = "The GCE resource labels (a map of key/value pairs) to be applied to the cluster"
  default     = {}
}

variable "master_ipv4_cidr_block" {
  type        = string
  description = "(Beta) The IP range in CIDR notation to use for the hosted master network"
  default     = "10.0.0.0/28"
}

variable "istio" {
  description = "(Beta) Enable Istio addon"
  default     = false
}

variable "letsencrypt" {
  description = "Letsencrypt will be used for certificate management so create service accounts for it."
  default     = true
}

variable "default_max_pods_per_node" {
  description = "The maximum number of pods to schedule per node"
  default     = 110
}

variable "database_encryption" {
  description = "Application-layer Secrets Encryption settings. The object format is {state = string, key_name = string}. Valid values of state are: \"ENCRYPTED\"; \"DECRYPTED\". key_name is the name of a CloudKMS key."
  type        = list(object({ state = string, key_name = string }))
  default = [{
    state    = "DECRYPTED"
    key_name = ""
  }]
}
variable "db_machine_type" {
  default = "db-f1-micro"
}

variable "db_version" {
  default = "POSTGRES_12"
}

variable "cloudrun" {
  description = "(Beta) Enable CloudRun addon"
  default     = false
}

variable "resource_usage_export_dataset_id" {
  type        = string
  description = "The dataset id for which network egress metering for this cluster will be enabled. If enabled, a daemonset will be created in the cluster to meter network egress traffic."
  default     = ""
}

variable "sandbox_enabled" {
  type        = bool
  description = "(Beta) Enable GKE Sandbox (Do not forget to set `image_type` = `COS_CONTAINERD` and `node_version` = `1.12.7-gke.17` or later to use it)."
  default     = false
}

variable "enable_intranode_visibility" {
  type        = bool
  description = "Whether Intra-node visibility is enabled for this cluster. This makes same node pod to pod traffic visible for VPC network"
  default     = false
}

variable "enable_vertical_pod_autoscaling" {
  type        = bool
  description = "Vertical Pod Autoscaling automatically adjusts the resources of pods controlled by it"
  default     = false
}

variable "authenticator_security_group" {
  type        = string
  description = "The name of the RBAC security group for use with Google security groups in Kubernetes RBAC. Group name must be in format gke-security-groups@yourdomain.com"
  default     = null
}

variable "compute_engine_service_account" {
  type        = string
  description = "Use the given service account for nodes rather than creating a new dedicated service account."
  default     = ""
}

variable "enable_shielded_nodes" {
  type        = bool
  description = "Enable Shielded Nodes features on all nodes in this cluster."
  default     = true
}

variable "enable_private_endpoint" {
  type        = bool
  description = "When true, the cluster's private endpoint is used as the cluster endpoint and access through the public endpoint is disabled. When false, either endpoint can be used. This field only applies to private clusters, when enable_private_nodes is true"
  default     = true
}

variable "skip_provisioners" {
  type        = bool
  description = "Flag to skip all local-exec provisioners. It breaks `stub_domains` and `upstream_nameservers` variables functionality."
  default     = false
}

variable "pod_security_policy_config" {
  type        = list(object({ enabled = bool }))
  description = "enabled - Enable the PodSecurityPolicy controller for this cluster. If enabled, pods must be valid under a PodSecurityPolicy to be created."

  default = [{
    "enabled" = true
  }]
}

variable "notification_list" {
  type = list(object({
    display_name = string
    email        = string
  }))
  default = [
    {
      display_name = "Bart"
      email        = "bart@springfield.com"
    },
    {
      display_name = "Lisa"
      email        = "lisa@springfield.com"
    },
    {
      display_name = "Marge"
      email        = "marge@springfield.com"
    }
  ]
}

locals {
  bastion_name = format("%s-bastion", var.cluster_name)
  stub_domains = {
    "${var.domain_name}" = [
      "10.254.154.11",
      "10.254.154.12",
    ]
  }
  node_pools = [
    {
      preemptible   = var.node_preemptible
      name          = "default-node-pool"
      min_count     = var.node_min_count
      max_count     = var.node_max_count
      machine_type  = var.node_machine_type
      auto_upgrade  = var.node_auto_upgrade
      node_metadata = "GKE_METADATA_SERVER"
    }
  ]
}
