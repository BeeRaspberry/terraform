# Google Cloud Instructions

This code leverages modules built by Google.

This code builds a private cluster with a bastion fronting the cluster. 

Options include creating a Google Cloud SQL database, or creating one within the cluster. If a Cloud SQL instance is created the code creates random passwords for a 'root' and 'api' password which is posted into Google's Secret Management system. These can then be access by other systems; aka: such as a CD pipeline.

## Quick Start

*   copy `terraform.tfvars.sample` to `terraform.tfvars`
*   customize `terraform.tfvars` to suit your needs
*   run `terraform init`
*   run `terraform plan` or `terraform plan -out <file name>`
*   run `terraform apply` or `terraform apply <file name>`

## Variables

**Note:** 
*   Default values exist for many of the required fields. Technically, they're required but have defaults for quick setup.
*   `variables.tf` include descriptions for the variables as well.

| Variable | Description | Default | Required | 
|-----------|-----------|-----------|-----------|  
| `cred_file` | full path of credential.json |  | Yes, unless credential is provided |
| `credential` | credential.json stored in a variable. Takes precendence over cred_file |  | No. But `cred_file` must be provided |
| `project_id` | The project used for the cluster. Note: This is may not be the same as the viewable project name | | Yes |
| `environment` | The 'environment' for the cluster. | development | Yes |
| `cluster_name` | The name of the cluster to create. |  my-cluster | Yes |
| `domain_name` | The domain name to associate with the cluster. This is optional. When provided, the code creates DNS Zone for the domain. | No |
| `region` | The region to place the cluster in. |  us-east1 | Yes |
| `subnet_ip` | The subnet ip range for the nodes. |  10.10.10.0/24 | Yes |
| `regional` | When true the cluster is limited to a single zone. WARNING: changing this after cluster creation is destructive!) |  true | Yes |
| `network_project_id` | The project ID of the shared VPC's host (for shared vpc support) |  '' | No |
| `ip_range_pods_name` | The secondary ip range to use for pods |  ip-range-pods | Yes |
| `ip_range_services_name` | The secondary ip range to use for services |  ip-range-services | Yes |
| `kubernetes_version` | The Kubernetes version to install on the master node |  latest | Yes |
| `master_authorized_networks` | Networks allowed to access the cluster | Bastion is auto added | Yes |
| `horizontal_pod_autoscaling` | Enable horizontal pod autoscaling addon | true | Yes |
| `http_load_balancing` | Enable httpload balancer addon. The addon allows whomever can create Ingress objects to expose an application to a public IP. Network policies or Gatekeeper policies should be used to verify that only authorized applications are exposed. | true | Yes |
| `maintenance_start_time` | Time window specified for daily maintenance operations in RFC3339 format | 05:00 | Yes |
| `initial_node_count` | The number of nodes to create in this cluster's default node pool. | 0 | Yes |
| `bastion_members` | List of users, groups, and system accounts needing access to the bastion host | [] | Yes |
| `ip_source_ranges_ssh` | Additional source ranges to allow for ssh to bastion host. 35.235.240.0/20 allowed by default for IAP tunnel. | [] | Yes |
| `node_min_count` | The minimum number of nodes to run in the cluster. | 1 | Yes |
| `node_max_count` | The maximum number of nodes running in the cluster. | 1 | Yes |
| `node_machine_type` | The machine type used by the nodes. | n2-standard-2 | Yes |
| `node_preemptible` | Use preemptible nodes to make the infrastructure cheaper to run. | true | Yes |
| `node_auto_upgrade` | Automatically update the nodes when new versions are available. | true | Yes |
 
