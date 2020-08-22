output "get_credentials_command" {
  description = "gcloud get-credentials command to generate kubeconfig for the private cluster"
  value       = format("gcloud container clusters get-credentials --project %s --zone %s --internal-ip %s", var.project_id, module.gke.location, module.gke.name)
}

output "bastion_ssh_command" {
  description = "gcloud command to ssh and port forward to the bastion host command"
  value       = format("gcloud compute ssh %s --tunnel-through-iap --project %s --zone %s -- -L 8888:127.0.0.1:8888", module.bastion.hostname, var.project_id, module.bastion.zone)
}

output "bastion_kubectl_command" {
  description = "kubectl command using the local proxy once the bastion_ssh command is running"
  value       = "HTTPS_PROXY=localhost:8888 kubectl get pods --all-namespaces"
}