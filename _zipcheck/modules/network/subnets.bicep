targetScope = 'resourceGroup'

@description('Name of the existing Virtual Network')
param vnetName string

@description('Subnet name for App Service Integration')
param subnetAppName string = 'snet-app'

@description('Subnet name for Key Vault Private Endpoint')
param subnetKvName string = 'snet-pe-kv'

@description('Subnet name for SQL Private Endpoint')
param subnetSqlName string = 'snet-pe-sql'

@description('Subnet name for Storage Private Endpoint')
param subnetStorageName string = 'snet-pe-storage'

@description('Address prefix for App subnet (must be inside VNet address space)')
param subnetAppPrefix string = '10.10.0.0/24'

@description('Address prefix for Key Vault PE subnet (must be inside VNet address space)')
param subnetKvPrefix string = '10.10.1.0/24'

@description('Address prefix for SQL PE subnet (must be inside VNet address space)')
param subnetSqlPrefix string = '10.10.2.0/24'

@description('Address prefix for Storage PE subnet (must be inside VNet address space)')
param subnetStoragePrefix string = '10.10.3.0/24'

/*
  Notes:
  - The App Service integration subnet MUST be delegated to Microsoft.Web/serverFarms.
  - Private Endpoint subnets must NOT have delegations.
  - Subnets are deployed sequentially to avoid "AnotherOperationInProgress" conflicts.
*/
resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

// App Service integration subnet (delegated)
resource subnetApp 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: subnetAppName
  properties: {
    addressPrefix: subnetAppPrefix

    // Required for App Service VNet Integration
    delegations: [
      {
        name: 'delegation-web-serverfarms'
        properties: {
          serviceName: 'Microsoft.Web/serverFarms'
        }
      }
    ]

    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// Key Vault Private Endpoint subnet
resource subnetKv 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: subnetKvName
  dependsOn: [
    subnetApp
  ]
  properties: {
    addressPrefix: subnetKvPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// Storage Private Endpoint subnet
resource subnetStorage 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: subnetStorageName
  dependsOn: [
    subnetKv
  ]
  properties: {
    addressPrefix: subnetStoragePrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

// SQL Private Endpoint subnet
resource subnetSql 'Microsoft.Network/virtualNetworks/subnets@2023-09-01' = {
  parent: vnet
  name: subnetSqlName
  dependsOn: [
    subnetStorage
  ]
  properties: {
    addressPrefix: subnetSqlPrefix
    privateEndpointNetworkPolicies: 'Disabled'
    privateLinkServiceNetworkPolicies: 'Enabled'
  }
}

output subnetAppId string = subnetApp.id
output subnetKvId string = subnetKv.id
output subnetStorageId string = subnetStorage.id
output subnetSqlId string = subnetSql.id
