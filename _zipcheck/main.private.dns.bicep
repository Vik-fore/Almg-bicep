targetScope = 'resourceGroup'

@description('Existing VNet name')
param vnetName string = 'vnet-alm-chatbot-prod'

// -------------------------
// Private DNS zone names
// -------------------------

var kvDnsZoneName = 'privatelink.vaultcore.azure.net'

// Suppress false-positive linter warning for DNS zone name

var blobDnsZoneName = 'privatelink.blob.core.windows.net'

// -------------------------
// Existing VNet
// -------------------------

resource vnet 'Microsoft.Network/virtualNetworks@2023-09-01' existing = {
  name: vnetName
}

// -------------------------
// Private DNS Zones
// Note: Private DNS resources use the "global" location.
// -------------------------

resource kvPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: kvDnsZoneName
  location: 'global'
}

resource blobPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: blobDnsZoneName
  location: 'global'
}

// -------------------------
// VNet Links (using parent property)
// -------------------------

resource kvDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: kvPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

resource blobDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  parent: blobPrivateDnsZone
  name: '${vnetName}-link'
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnet.id
    }
    registrationEnabled: false
  }
}

// -------------------------
// Outputs
// -------------------------

output kvPrivateDnsZoneId string = kvPrivateDnsZone.id
output blobPrivateDnsZoneId string = blobPrivateDnsZone.id
