# appending random characters to some fields that need to be globally unique
resource "random_id" "name_suffix" {
  byte_length = 4
}

resource "azurerm_resource_group" "vault_rg" {
  name     = var.rg_name
  location = var.location
}

data "azurerm_subscription" "primary" {}

data "azurerm_client_config" "current" {}


#---------------------------
# ACR
#---------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry
resource "azurerm_container_registry" "vault_acr" {
  name                = "${var.acr_name}${random_id.name_suffix.hex}"
  resource_group_name = azurerm_resource_group.vault_rg.name
  location            = azurerm_resource_group.vault_rg.location
  sku                 = "Basic"
  admin_enabled       = false

  identity {
    type = "UserAssigned"
    identity_ids = [
      azurerm_user_assigned_identity.vault_user.id
    ]
  }
}


#---------------------------
# Storage Account
#---------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account
resource "azurerm_storage_account" "vault_storage_account" {
  name                     = "${var.storage_account_name}${random_id.name_suffix.hex}"
  resource_group_name      = azurerm_resource_group.vault_rg.name
  location                 = azurerm_resource_group.vault_rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

}

# storage share to be mounted on ACI container
# will only hold the vault-config.hcl
resource "azurerm_storage_share" "vault_config" {
  name                 = var.storage_share_name
  storage_account_name = azurerm_storage_account.vault_storage_account.name
  quota                = 1
}

resource "azurerm_storage_container" "vault_data" {
  name                  = var.storage_container_name
  storage_account_name  = azurerm_storage_account.vault_storage_account.name
  container_access_type = "private"
}


#---------------------------
# Key Vault 
#---------------------------
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault
resource "azurerm_key_vault" "vault_akv" {
  name                       = "${var.akv_name}${random_id.name_suffix.hex}"
  location                   = azurerm_resource_group.vault_rg.location
  resource_group_name        = azurerm_resource_group.vault_rg.name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = "standard"
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = false

  network_acls {
    default_action = "Allow"
    bypass         = "AzureServices"
  }
}

resource "azurerm_key_vault_access_policy" "akv_ap" {
  key_vault_id = azurerm_key_vault.vault_akv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  key_permissions = [
    "Create",
    "Delete",
    "Get",
    "List",
    "Purge",
    "Update",
    "GetRotationPolicy",
  ]
}

resource "azurerm_key_vault_access_policy" "vault_user_akv_ap" {
  key_vault_id = azurerm_key_vault.vault_akv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = azurerm_user_assigned_identity.vault_user.principal_id

  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey",
    "GetRotationPolicy",
  ]
}

resource "azurerm_key_vault_key" "vault_key" {
  name         = "vault-unseal-key"
  key_vault_id = azurerm_key_vault.vault_akv.id
  key_type     = "RSA"
  key_size     = 2048

  key_opts = [
    "decrypt",
    "encrypt",
    "sign",
    "unwrapKey",
    "verify",
    "wrapKey",
  ]

  # https://github.com/hashicorp/terraform-provider-azurerm/issues/4569#issuecomment-611488341
  depends_on = [azurerm_key_vault_access_policy.vault_user_akv_ap]
}


#--------------------------------------
# Vault Server Config Templating
#--------------------------------------

data "template_file" "vault_server_config" {
  template = file("./azure-container-instances/vault-server.hcl.tpl")
  vars = {
    az_storage_account_name   = "${azurerm_storage_account.vault_storage_account.name}"
    az_storage_account_key    = "${nonsensitive(azurerm_storage_account.vault_storage_account.primary_access_key)}"
    az_storage_container_name = "${azurerm_storage_container.vault_data.name}"
  }
}

# https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/file
resource "local_file" "rendered_vault_config" {
  content         = data.template_file.vault_server_config.rendered
  filename        = "./azure-container-instances/vault-server.hcl"
  file_permission = "0644"
}
