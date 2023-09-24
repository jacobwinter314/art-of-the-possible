terraform {
  required_version = ">= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }
}

resource "azurerm_container_registry" "main_acr" {
  resource_group_name = var.resource_group_name
  location            = var.location
  name                = "cr${var.workload_name}${var.environment_name}${var.location}"

  admin_enabled                 = var.admin_enabled
  sku                           = var.sku_name
  public_network_access_enabled = true

  lifecycle {
    ignore_changes = [tags]
  }
}
