targetScope = 'resourceGroup'

@description('Deployment location')
param location string = resourceGroup().location

@description('VNet name')
param vnetName string = 'vnet-alm-chatbot-prod'

@description('VNet address space')
param vnetAddressSpace array = [
  '10.10.0.0/16'
]

// Subnet prefixes
param subnetAppPrefix string = '10.10.0.0/24'
param subnetKvPrefix string = '10.10.1.0/24'
param subnetStoragePrefix string = '10.10.3.0/24'
param subnetSqlPrefix string = '10.10.2.0/24'

module vnet 'modules/network/vnet.bicep' = {
  name: 'deploy-vnet'
  params: {
    vnetName: vnetName
    location: location
    addressSpace: vnetAddressSpace
  }
}

module subnets 'modules/network/subnets.bicep' = {
  name: 'deploy-subnets'
  params: {
    vnetName: vnetName
    subnetAppPrefix: subnetAppPrefix
    subnetKvPrefix: subnetKvPrefix
    subnetStoragePrefix: subnetStoragePrefix
    subnetSqlPrefix: subnetSqlPrefix
  }
  dependsOn: [
    vnet
  ]
}

output vnetId string = vnet.outputs.vnetId
output subnetAppId string = subnets.outputs.subnetAppId
output subnetKvId string = subnets.outputs.subnetKvId
output subnetStorageId string = subnets.outputs.subnetStorageId
output subnetSqlId string = subnets.outputs.subnetSqlId
