# Vault on Azure Container Instances

[Azure Container Registry](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/container_registry)

[Azure Storage Account](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account)

[Azure Key Vault](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/key_vault)

In June 2021, I released [Free-tier Vault with Cloud Run](https://github.com/Neutrollized/hashicorp-vault-with-cloud-run), which allow you to deploy HashiCorp Vault on Google Cloud full managed serverless container platform, Cloud Run. GCP is my primary (and favorite) cloud provider, but I thought I'd try to make a similar deployment equivalent on Azure's [Container Instances](https://azure.microsoft.com/en-us/services/container-instances/) and AWS' [Fargate](https://aws.amazon.com/fargate/) (currently WIP).  I figured this would allow me to learn a bit more about Azure and AWS' offerings.

HashiCorp's products makes this possible by offering binaries for all sorts of architectures and operating systems, so whether you're on a Mac or Windows or Raspberry Pi, there's a binary for you!

**NOTE:** I am once again building my own Vault Docker image because I wanted to learn how the IAM piece works with Azure and also using their managed [Azure Container Registry](https://azure.microsoft.com/en-us/services/container-registry/).  You can just as easily use the HashiCorp provided Docker image when deploying your ACI.

This repo contains Terraform code that will deploy the required underlying infrastructure (Container Registry, Storage, Key Vault for auto-unseal), but the user will have to perform some tasks via the [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli), `az`.  The details of those command can be found [here](./azure-container-instances/README.md)


## How the Services are used
### Storage Account (File shares)
Azure doesn't have a secrets manager offering where entired config files and be stored as secrets and mounted into the container as a secret, and hence we will have to use file shares and mount the volume containing our config file like an NFS mount.

### Storage Account (Containers)
I'm referring to storage containers, which will serve as the [storage backend](https://www.vaultproject.io/docs/configuration/storage/azure) for the Vault data (the Google Cloud Storage or AWS S3 equivalent).

### Key Vault
Used for [auto-unseal](https://www.vaultproject.io/docs/concepts/seal#auto-unseal)

### Container Instances
Where the Vault binary will be run from.  

### Azure DevOps (optional, currently DISABLED)
You will have to [create an organization](https://docs.microsoft.com/en-us/azure/devops/organizations/accounts/create-organization?view=azure-devops) first and by default it woud be your username.  Azure is not my forte, but from what I learned playing around with [Azure Pipelines](https://azure.microsoft.com/en-us/services/devops/pipelines/), you will need a file in your repo called `azure-pipelines.yaml`, except there's a lot of information that gets put in there that I wouldn't really be that comfortable putting in from an overall security point of view.  So while I do have the a block of code here dedicated to setting up Azure DevOps for the building and deployment of the Vault ACI, I'm opting to leave it as DISABLED -- but for those of you have have more knowledge in the Azure DevOps domain, please feel free to make PR to educate me on how best to approach this.
