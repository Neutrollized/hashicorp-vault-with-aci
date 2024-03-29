# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.4.2] - 2023-04-07
### Changed
- Split Azure Key Vault access policy into its own resource
### Fixed
- Added `depends_on` clause for `azurerm_key_vault_key` to fix [issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/4569)

## [0.4.1] - 2023-04-06
### Changed
- `azure-container-instances/vault-server.hcl` will be templated out via `template_file` and `local_file` Terraform resources

## [0.4.0] - 2023-04-05
### Added
- Variable type constraints
- Additional `features` to **azurerm** provider
### Fixed
- Added built-in roles `Key Vault Secrets User` and `Key Vault Crypto User` to vault-user

## [0.3.0] - 2023-04-04
### Changed
- Updated `cloud-run/init.json` to remove `secret_shares` and `secret_threshold` as part of [GH-16379](https://github.com/hashicorp/vault/pull/16379) applied to v1.12.0
- Updated README notes on Azure DevOps
- Updated Vault version from `1.11.2` to `1.13.1`

## [0.2.0] - 2022-08-29
### Added
- Azure DevOps setup (currently disabled, see README for my reasons)
- **azuredevops** providers
- [`terraform.tfvars.template`](./terraform.tfvars.template)
### Changed
- Updated Vault version from `1.10.4` to `1.11.2`
### Fixed
- Added `Purge` key permission to `azurerm_key_vault` to fix Terraform destroy error when delete the AKV key

## [0.1.0] - 2022-06-14
### Added
- Initial commit
