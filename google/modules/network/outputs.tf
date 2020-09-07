output "db_network" {
  description = "DB Private network"
  value       = module.vpc.network.network.id
}

output "subnetwork" {
  description = "Subnet network"
  value       = module.vpc.subnets_names[0]
}

output "ip_range_pods" {
  description = "IP Range for Pods"
  value       = module.vpc.subnets_secondary_ranges[0].*.range_name[0]
}

output "ip_range_services" {
  description = "IP Range for Services"
  value       = module.vpc.subnets_secondary_ranges[0].*.range_name[1]
}

output "network_name" {
  description = "Network Name"
  value       = module.vpc.network_name
}

output "bastion_network" {
  description = "Bastion Network"
  value       = module.vpc.network_self_link
}

output "bastion_subnet" {
  description = "Bastion Subnet"
  value       = module.vpc.subnets_self_links[0]
}

output "db_depends_on" {
  description = "DB Depends on network"
  value       = google_service_networking_connection.peering_connection.service
}