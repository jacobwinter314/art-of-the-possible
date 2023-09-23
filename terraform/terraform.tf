terraform {
  required_version = ">= 1.5.7"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "rg-artpossiblest-dev-westus"
    storage_account_name = "startpossiblestdevwestus"
    container_name       = "tfstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}
