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
  workload_name    = "artpossiblest"
  environment_name = "dev"
  location         = "westus"

  # common_tags = {
  #   Component   = "ArtOfThePossible"
  # }
}


provider "azurerm" {
  features {}
}
