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

| Variable | Description | Possible Values | Required | 
|-----------|:-----------:|-----------:|-----------:|  
| `cred_file` | full path of credential.json |  | Yes, unless credential is provided |
| `credential` | credential.json stored in a variable. Takes precendence over cred_file |  | No. But `cred_file` must be provided |
| `project_id` | The project used for the cluster. Note: This is may not be the same as the viewable project name | | Yes |
| `environment` | The 'environment' for the cluster. | **Default:** development | Yes |
| `cluster_name` | The name of the cluster to create. | **Default:** my-cluster | Yes |
| `domain_name` | The domain name to associate with the cluster. This is optional. When provided, the code creates DNS Zone for the domain. | No |
| `region` | The region to place the cluster in. | **Default:** us-east1 | Yes |
| `subnet_ip` | The subnet ip range for the nodes. | **Default:** 10.10.10.0/24 | Yes |
| `regional` | When true the cluster is limited to a single zone. WARNING: changing this after cluster creation is destructive!) | **Default:** true | Yes |
| `network_project_id` | The project ID of the shared VPC's host (for shared vpc support) | **Default:** '' | No |
| `ip_range_pods_name` | The secondary ip range to use for pods | **Default:** ip-range-pods | Yes |
| `ip_range_services_name` | The secondary ip range to use for services | **Default:** ip-range-services | Yes |
| `kubernetes_version` | The Kubernetes version to install on the master node | **Default:** latest | Yes |
| `master_authorized_networks` | Networks allowed to access the cluster | Bastion is auto added | Yes |
| `horizontal_pod_autoscaling` | Enable horizontal pod autoscaling addon | **Default:** true | Yes |