output "api_password" {
  description = "api user password"
  value       = random_string.db-api-pwd.result
}