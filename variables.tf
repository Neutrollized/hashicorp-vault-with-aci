#-----------------------
# Azure basic vars
#-----------------------
variable "rg_name" {
  default = "vault-rg"
}

variable "location" {
  default = "canadacentral"
}


#-------------------------
# ACR
#-------------------------

variable "acr_name" {
  description = "Name of Azure Container Registry repo. Alphanumeric characters only without spaces."
  default     = "vaultacr"
}


#-------------------------
# Storage Account
#-------------------------
variable "storage_account_name" {
  description = "Name of Azure storage account. Lowercase alphanumeric characters only."
  default     = "vaultstorage"
}

variable "storage_share_name" {
  description = "Name of storage share used to hold the vault-server.hcl to be mounted onto ACI."
  default     = "vault-config"
}

variable "storage_container_name" {
  description = "Name of storage container used as Vault's storage backend."
  default     = "vault-data"
}


#-------------------------
# Azure Key Vault
#-------------------------
variable "akv_name" {
  description = "Name of AKV used to store key used for Auto-unseal."
  default     = "vault-akv"
}

variable "soft_delete_retention_days" {
  default = 7
}


#-------------------------
# HashiCorp Vault 
#-------------------------
variable "vault_name" {
  default = "azvault"
}

variable "vault_version" {
  default = "1.10.4"
}
