resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.workload_name}-${local.environment_name}-${local.location}"
  location = local.location
}

resource "azurerm_storage_account" "tfstate" {
  name                = "st${local.workload_name}${local.environment_name}${local.location}"
  location            = azurerm_resource_group.tfstate.location
  resource_group_name = azurerm_resource_group.tfstate.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "tfstate" {
  name = "tfstate"

  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}
