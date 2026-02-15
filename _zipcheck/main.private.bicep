targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

// Existing resource names (already deployed)
@description('VNet name (already exists)')
param vnetName string = 'vnet-alm-chatbot-prod'

@description('Key Vault name (already exists)')
param keyVaultName string = 'kv-almchatbot-prod-weu'

@description('Storage account name (already exists)')
param storageAccountName string = 'stalmchatbotprod'

// Subnet names for Private Endpoints
@description('Subnet name for Key Vault Private Endpoint')
param subnetKvName string = 'snet-pe-kv'

@description('Subnet name for Storage Private Endpoint')
param subnetStorageName string = 'snet-pe-storage'

// Private Endpoint resource names
@description('Private Endpoint name for Key Vault')
param peKvName string = 'pe-${keyVaultName}'

@description('Private Endpoint name for Storage Blob')
param peStorageBlobName string = 'pe-${storageAccountName}-blob'

// ---- Existing resources ----
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

resource subnetKv 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetKvName
}

resource subnetStorage 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' existing = {
  parent: vnet
  name: subnetStorageName
}

resource keyVault 'Microsoft.KeyVault/vaults@2023-07-01' existing = {
  name: keyVaultName
}

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' existing = {
  name: storageAccountName
}

// ---- Private Endpoints ----

// Key Vault Private Endpoint (groupId must be 'vault')
module peKeyVault './modules/network/privateEndpoint.bicep' = {
  name: 'deploy-pe-kv'
  params: {
    privateEndpointName: peKvName
    location: location
    privateSubnetId: subnetKv.id
    privateLinkServiceId: keyVault.id
    subresourceName: 'vault'
  }
}

// Storage Blob Private Endpoint (groupId must be 'blob')
module peStorageBlob './modules/network/privateEndpoint.bicep' = {
  name: 'deploy-pe-storage-blob'
  params: {
    privateEndpointName: peStorageBlobName
    location: location
    privateSubnetId: subnetStorage.id
    privateLinkServiceId: storage.id
    subresourceName: 'blob'
  }
}

output peKeyVaultId string = peKeyVault.outputs.privateEndpointId
output peStorageBlobId string = peStorageBlob.outputs.privateEndpointId
