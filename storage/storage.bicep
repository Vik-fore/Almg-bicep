targetScope = 'resourceGroup'

@description('Name of the Storage Account for PROD')
param storageAccountName string = 'stalmchatbotprodweu01'  

@description('Location')
param location string = 'westeurope'

@description('SKU / Replication type')
param storageSkuName string = 'Standard_GRS'

@description('Allow public blob access')
param allowBlobPublicAccess bool = false

@description('Minimum TLS version')
param minTlsVersion string = 'TLS1_2'

@description('Enable public network access (true = Enabled, false = Disabled)')
param publicNetworkAccess bool = false  

@description('Default action for network rules (Allow or Deny)')
param defaultNetworkAction string = 'Deny'  

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: storageSkuName
  }
  kind: 'StorageV2'
  properties: {
    accessTier: 'Hot'
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: minTlsVersion
    supportsHttpsTrafficOnly: true
    publicNetworkAccess: publicNetworkAccess ? 'Enabled' : 'Disabled'  
    encryption: {
      services: {
        blob: { enabled: true }
        file: { enabled: true }
      }
      keySource: 'Microsoft.Storage'
    }
    networkAcls: {  // NEW: Network rules
      bypass: 'AzureServices'  // Allow Azure services (like Log Analytics)
      defaultAction: defaultNetworkAction  // 'Deny' = secure
      ipRules: []
      virtualNetworkRules: []
    }
  }
}

output storageAccountId string = storageAccount.id
output storageAccountName string = storageAccount.name
output storageAccountBlobEndpoint string = storageAccount.properties.primaryEndpoints.blob
