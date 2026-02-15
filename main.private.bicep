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

// ============================================================================
// Existing resources
// ============================================================================
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

// ============================================================================
// Private Endpoints
// ============================================================================

// Key Vault Private Endpoint
// groupIds must be ['vault'] for Key Vault
resource peKeyVault 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: peKvName
  location: location
  properties: {
    subnet: {
      id: subnetKv.id
    }
    privateLinkServiceConnections: [
      {
        name: '${peKvName}-pls'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: [
            'vault'
          ]
          requestMessage: 'Private Endpoint for Key Vault'
        }
      }
    ]
  }
}

// Storage Blob Private Endpoint
// groupIds must be ['blob'] for Storage Blob
resource peStorageBlob 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: peStorageBlobName
  location: location
  properties: {
    subnet: {
      id: subnetStorage.id
    }
    privateLinkServiceConnections: [
      {
        name: '${peStorageBlobName}-pls'
        properties: {
          privateLinkServiceId: storage.id
          groupIds: [
            'blob'
          ]
          requestMessage: 'Private Endpoint for Storage Blob'
        }
      }
    ]
  }
}

// ============================================================================
// Outputs
// ============================================================================
output peKeyVaultId string = peKeyVault.id
output peStorageBlobId string = peStorageBlob.id
