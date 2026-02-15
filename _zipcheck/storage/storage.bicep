@description('Name of the Storage Account for PROD')
param storageAccountName string = 'stalmchatbotprod'

@description('Location')
param location string = 'westeurope'

@description('SKU / Replication type')
param storageSkuName string = 'Standard_GRS'

@description('Allow public blob access?')
param allowBlobPublicAccess bool = false

@description('Minimum TLS version')
param minTlsVersion string = 'TLS1_2'

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: minTlsVersion
    allowBlobPublicAccess: allowBlobPublicAccess
    supportsHttpsTrafficOnly: true
    
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Deny'
      ipRules: []
      virtualNetworkRules: []
    }

    encryption: {
      services: {
        blob: { enabled: true }
        file: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
    }
  }
}

output storageId string = storageAccount.id
