#-----------------------
# Azure basic vars
#-----------------------
variable "rg_name" {
  type    = string
  default = "vault-rg"
}

variable "location" {
  type    = string
  default = "canadacentral"
}


#-------------------------
# ACR
#-------------------------

variable "acr_name" {
  description = "Name of Azure Container Registry repo. Alphanumeric characters only without spaces."
  type        = string
  default     = "vaultacr"
}


#-------------------------
# Storage Account
#-------------------------
variable "storage_account_name" {
  description = "Name of Azure storage account. Lowercase alphanumeric characters only."
  type        = string
  default     = "vaultstorage"
}

variable "storage_share_name" {
  description = "Name of storage share used to hold the vault-server.hcl to be mounted onto ACI."
  type        = string
  default     = "vault-config"
}

variable "storage_container_name" {
  description = "Name of storage container used as Vault's storage backend."
  type        = string
  default     = "vault-data"
}


#-------------------------
# Azure Key Vault
#-------------------------
variable "akv_name" {
  description = "Name of AKV used to store key used for Auto-unseal."
  type        = string
  default     = "vault-akv"
}

variable "soft_delete_retention_days" {
  type    = number
  default = 7
}


#-------------------------
# HashiCorp Vault 
#-------------------------
variable "vault_name" {
  type    = string
  default = "azvault"
}

variable "vault_version" {
  type    = string
  default = "1.10.4"
}
