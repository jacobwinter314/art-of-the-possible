terraform {
  required_version = ">= 1.4.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "=3.4.3"
      }
  }
}

locals {
  workload_name  = "artpossiblest"
  environment_name  = "dev"
  location  = "westus"

  # common_tags = {
  #   Component   = "ArtOfThePossible"
  # }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "tfstate" {
  name     = "rg-${local.workload_name}-${local.environment_name}-${local.location}"
  location = local.location
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "st${local.workload_name}${local.environment_name}${local.location}"
  location                 = azurerm_resource_group.tfstate.location
  resource_group_name      = azurerm_resource_group.tfstate.name

  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_blob_public_access = false
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "tfstate"

  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

output "resource_group" {
value = azurerm_resource_group.tfstate.name
}

output "storage_account_name" {
  value = azurerm_storage_account.tfstate.name
}

output "container_name" {
value = azurerm_storage_container.tfstate.name
}
