locals {
  workload_name    = "artpossible"
  environment_name = "dev"
  location         = "westus"

  common_tags = {
    Component = "ArtOfThePossible"
  }
}

resource "azurerm_resource_group" "main_rg" {
  name     = "rg-${local.workload_name}-${local.environment_name}-${local.location}"
  location = local.location

  tags = (merge(
    local.common_tags,
    tomap({})
  ))

  lifecycle {
    ignore_changes = [tags]
  }
}

module "container-registry" {
  source = "./modules/container-registry"

  workload_name       = local.workload_name
  environment_name    = local.environment_name
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  admin_enabled = var.acr_allow_admin_access
  sku_name      = var.acr_sku_name
}


output "acr_server_url" {
  description = "Url used to log in to the ACR with."
  value       = module.container-registry.acr_server_url
}

output "acr_client_id" {
  description = "If admin_enabled, the client id for the ACR."
  value       = module.container-registry.admin_username
}

output "acr_client_secret" {
  description = "If admin_enabled, the admin password for the ACR."
  value       = module.container-registry.admin_password
  sensitive   = true
}
