output "_0_vault_config_upload" {
  value = "az storage file upload --account-name ${azurerm_storage_account.vault_storage_account.name} --share-name ${azurerm_storage_share.vault_config.name} --source vault-server.hcl"
}

output "_1_image_build" {
  value = "az acr build --image vault:${var.vault_version} --registry ${azurerm_container_registry.vault_acr.name} --file Dockerfile ."
}

output "_2_container_instance_create" {
  value = <<EOT
az container create --resource-group ${azurerm_resource_group.vault_rg.name} \
  --name ${var.vault_name} --image ${azurerm_container_registry.vault_acr.name}.azurecr.io/vault:${var.vault_version} \
  --acr-identity ${azurerm_user_assigned_identity.vault_user.id} \
  --command-line '/vault server -config /etc/vault/vault-server.hcl' \
  --dns-name-label ${var.vault_name} \
  --ports 8200 \
  --azure-file-volume-account-name ${azurerm_storage_account.vault_storage_account.name} \
  --azure-file-volume-share-name ${azurerm_storage_share.vault_config.name} \
  --azure-file-volume-account-key ${nonsensitive(azurerm_storage_account.vault_storage_account.primary_access_key)} \
  --azure-file-volume-mount-path /etc/vault \
  --assign-identity ${azurerm_user_assigned_identity.vault_user.id} \
  --environment-variables AZURE_TENANT_ID=${data.azurerm_client_config.current.tenant_id} \
  VAULT_AZUREKEYVAULT_VAULT_NAME=${azurerm_key_vault.vault_akv.name} \
  VAULT_AZUREKEYVAULT_KEY_NAME=${azurerm_key_vault_key.vault_key.name}
EOT
}

output "_3_initialize_vault" {
  value = <<EOT
export VAULT_ADDR="http://${var.vault_name}.${var.location}.azurecontainer.io:8200"
curl -s -X POST $${VAULT_ADDR}/v1/sys/init --data @init.json
EOT
}
