# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2022-08-29
### Added
- Azure DevOps setup (currently disabled, see README for my reasons)
- **azuredevops** providers
- [`terraform.tfvars.template`](./terraform.tfvars.template)
### Changed
- updated Vault version from `1.10.4` to `1.11.2`
### Fixed
- added `Purge` key permission to `azurerm_key_vault` to fix Terraform destroy error when delete the AKV key

## [0.1.0] - 2022-06-14
### Added
- Initial commit
