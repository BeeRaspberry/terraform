output "db_network" {
  description = "DB Private network"
  value       = module.vpc.network_self_link
}