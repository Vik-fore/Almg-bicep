targetScope = 'resourceGroup'

@description('Virtual Network name')
param vnetName string

@description('Deployment location')
param location string = resourceGroup().location

@description('VNet address space prefixes')
param addressSpace array

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: addressSpace
    }
  }
}

output vnetId string = vnet.id
output vnetNameOut string = vnet.name
