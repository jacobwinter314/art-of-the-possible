
output "acr_server_url" {
  description = "Url for the ACR to log in to."
  value       = azurerm_container_registry.main_acr.login_server
}

output "admin_username" {
  description = "If admin_enabled, the admin user name for the ACR."
  value       = azurerm_container_registry.main_acr.admin_username
}

output "admin_password" {
  description = "If admin_enabled, the admin password for the ACR."
  value       = azurerm_container_registry.main_acr.admin_password
  sensitive = true
}
