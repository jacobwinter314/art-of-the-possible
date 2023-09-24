terraform {
  required_version = ">= 1.4.2"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.71.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.23.0"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
    time = {
      source  = "hashicorp/time"
      version = "0.9.1"
    }
  }
  backend "azurerm" {
    resource_group_name  = "rg-artpossiblest-dev-westus"
    storage_account_name = "startpossiblestdevwestus"
    container_name       = "tfstate"
    key                  = "terraform-deploy.tfstate"
  }
}

provider "azurerm" {
  features {}
}
