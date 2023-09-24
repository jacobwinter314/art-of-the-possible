resource "azapi_resource_action" "ssh_public_key_gen" {
  resource_id = azapi_resource.ssh_public_key.id

  type   = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  action = "generateKeyPair"
  method = "POST"

  response_export_values = ["publicKey", "privateKey"]
}

resource "azapi_resource" "ssh_public_key" {
  name     = "ssh-${local.workload_name}-${local.environment_name}-${local.location}"
  location = azurerm_resource_group.main_rg.location

  type      = "Microsoft.Compute/sshPublicKeys@2022-11-01"
  parent_id = azurerm_resource_group.main_rg.id
}
