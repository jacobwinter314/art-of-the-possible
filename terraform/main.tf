locals {
  workload_name    = "artpossible"
  environment_name = "dev"
  location         = "westus"

  cluster_username = "clusteradmin"

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

resource "azurerm_kubernetes_cluster" "k8s" {
  name                = "aks-${local.workload_name}-${local.environment_name}-${local.location}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  dns_prefix = "dns-aks-${local.workload_name}-${local.environment_name}-${local.location}"

  identity {
    type                      = "UserAssigned"
    user_assigned_identity_id = azurerm_user_assigned_identity.k8s_identity.id
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_D2_v2"
    node_count = 1
  }

  role_based_access_control {
    enabled = true
  }

  linux_profile {
    admin_username = local.cluster_username

    ssh_key {
      key_data = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_user_assigned_identity" "k8s_identity" {
  name                = "id-${local.workload_name}-${local.environment_name}-${local.location}"
  location            = azurerm_resource_group.main_rg.location
  resource_group_name = azurerm_resource_group.main_rg.name

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_role_assignment" "acr_role" {
  scope                            = module.container-registry.acr_azure_id
  role_definition_name             = "AcrPull"
  principal_id                     = azurerm_user_assigned_identity.k8s_identity.principal_id
  skip_service_principal_aad_check = true
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

output "key_data" {
  value = jsondecode(azapi_resource_action.ssh_public_key_gen.output).publicKey
}
