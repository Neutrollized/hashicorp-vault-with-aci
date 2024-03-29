# README

## Deployment
#### 0 - Upload `vault-server.hcl` to File Share
```console
az storage file upload --account-name ${STORAGE_ACCOUNT_NAME} --share-name ${STORAGE_SHARE_NAME} --source vault-server.hcl
```

- example output:
```
Finished[#############################################################]  100.0000%
{
  "content_md5": "0x1c0x470xe20x630x890x500x2f0xc50xaa0x6c0x790xb20xc90x4a0x60x8c",
  "date": "2023-04-07T02:16:14+00:00",
  "etag": "\"0x8DB370E10807CFE\"",
  "file_last_write_time": "2023-04-07T02:16:14.8983038Z",
  "last_modified": "2023-04-07T02:16:14+00:00",
  "request_id": "4b000ac2-001a-005f-48f6-68dbf6000000",
  "request_server_encrypted": true,
  "version": "2021-06-08"
}
```

**NOTE:** we are passing the settings for auto-unseal via environment variables at ACI creation time (see below)


#### 1 - Build the Image
```console
az acr build --image vault:1.11.2 --registry ${ACR_NAME} --file Dockerfile . 
```

- example output:
```
Packing source code into tar to upload...
Uploading archived source code from '/var/folders/58/16lnyx815c183j6wzcbl_thc0000gn/T/build_archive_4cc7a8f32603442fa79777734653ed25.tar.gz'...
Sending context (1.251 KiB) to registry: vaultacrac447bf6...
Queued a build with ID: cw1
Waiting for an agent...
2022/06/14 16:20:39 Downloading source code...
2022/06/14 16:20:39 Finished downloading source code
2022/06/14 16:20:40 Using acb_vol_055f7e0b-c408-4da2-a9a9-941440cbc5ba as the home volume
2022/06/14 16:20:40 Setting up Docker configuration...
...
...
...
2022/06/14 16:21:15 Step ID: push marked as successful (elapsed time in seconds: 9.026451)
2022/06/14 16:21:15 The following dependencies were found:
2022/06/14 16:21:15
- image:
    registry: vaultacrac447bf6.azurecr.io
    repository: vault
    tag: 1.11.2
    digest: sha256:4b0e51757931ed23b784676603fc29064cda34a8bbe137da93dd077af87c7ad9
  runtime-dependency:
    registry: registry.hub.docker.com
    repository: library/scratch
    tag: latest
  buildtime-dependency:
  - registry: registry.hub.docker.com
    repository: library/debian
    tag: buster
    digest: sha256:e5b41ae2b4cf0d04b80cd2f89724e9cfc09e334ac64f188b9808929c748af526
  - registry: registry.hub.docker.com
    repository: library/alpine
    tag: latest
    digest: sha256:686d8c9dfa6f3ccfc8230bc3178d23f84eeaf7e457f36f271ab1acc53015037c
  git: {}

Run ID: cw1 was successful after 37s
```


#### 2 - Deploy Vault on ACI
- your ACI create command that's specific to you should be in the Terraform output
```console
az container create --resource-group ${RG_NAME} \
  --name ${ACI_NAME} \
  --image ${ACR_NAME}/vault:1.11.2 \
  --acr-identity ${USER_ASSIGNED_IDENTITY} \
  --command-line '/vault server -config /etc/vault/vault-server.hcl' \
  --dns-name-label ${ACI_NAME} \
  --ports 8200 \
  --azure-file-volume-account-name ${STORAGE_ACCOUNT_NAME} \
  --azure-file-volume-share-name vault-config \
  --azure-file-volume-account-key ${STORAGE_ACCOUNT_ACCESS_KEY} \
  --azure-file-volume-mount-path /etc/vault \
  --assign-identity ${USER_ASSIGNED_IDENTITY} \
  --environment-variables AZURE_TENANT_ID=${AZURE_TENANT_ID} \
  VAULT_AZUREKEYVAULT_VAULT_NAME=${AKV_NAME} \
  VAULT_AZUREKEYVAULT_KEY_NAME=${AKV_UNSEAL_KEY_NAME}
```

**NOTE:** the above deployment references custom paths used in my Docker image.  If you choose the HashiCorp managed image, paths to the `vault` executable and configs may vary.


#### 3 - Initialize Vault
```console
export VAULT_ADDR="http://${ACI_NAME}.${AZURE_LOCATION}.azurecontainer.io:8200"
curl -s -X POST ${VAULT_ADDR}/v1/sys/init --data @init.json
```

**NOTE:** it may take a few minutes for the provided URL to resolve, so if initialization doesn't work initially, wait a little and then try again

## IMPORTANT!!
Azure Container Instances does not support/provide a managed SSL cert option (which GCP does) and so I purposely opted *not* to use a self-signed cert and use HTTP to highlight this shortcoming.  You can always purchase a cert through the cloud provider, but it will incur extra costs.


## Clean up
#### 1 - Delete ACI
```console
az container delete --resource-group ${RG_NAME} --name ${ACI_NAME}
```

#### 2 - Destroy Resources
```console
terraform destroy -auto-approve
```

**NOTE:** you may encounter an error with deleting the AKV key with Terraform because of [this issue](https://github.com/hashicorp/terraform-provider-azurerm/issues/19307)
