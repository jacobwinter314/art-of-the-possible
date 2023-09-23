locals {
  workload_name  = "artpossible"
  environment_name  = "dev"
  location  = "westus"

  common_tags = {
    Component   = "ArtOfThePossible"
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
