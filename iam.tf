# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity
resource "azurerm_user_assigned_identity" "vault_user" {
  resource_group_name = azurerm_resource_group.vault_rg.name
  location            = azurerm_resource_group.vault_rg.location

  name = "vault-user"
}

# https://docs.microsoft.com/en-us/azure/container-instances/using-azure-container-registry-mi
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment
resource "azurerm_role_assignment" "vault_user_acr" {
  scope                = azurerm_container_registry.vault_acr.id
  role_definition_name = "Reader"
  principal_id         = azurerm_user_assigned_identity.vault_user.principal_id
}
