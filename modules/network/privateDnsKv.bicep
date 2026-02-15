targetScope = 'resourceGroup'

@description('Resource ID of the Virtual Network to link the Private DNS zone to.')
param vnetId string

@description('Name of the VNet link resource inside the Private DNS zone.')
param vnetLinkName string = 'vnetlink-kv'

// Build the Key Vault DNS suffix using the current Azure environment
var kvDnsSuffix = environment().suffixes.keyvaultDns // usually: vaultcore.azure.net
var privateDnsZoneName = 'privatelink.${kvDnsSuffix}'

// Private DNS Zone for Key Vault Private Link
resource kvPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

// Link the Private DNS zone to the VNet
resource kvDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vnetLinkName
  parent: kvPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    // Do not auto-register records; Private Endpoint DNS zone group will create A-records.
    registrationEnabled: false
  }
}

output kvPrivateDnsZoneId string = kvPrivateDnsZone.id
output kvPrivateDnsZoneName string = kvPrivateDnsZone.name
