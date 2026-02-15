targetScope = 'resourceGroup'

@description('Resource ID of the Virtual Network to link the Private DNS zone to.')
param vnetId string

@description('Name of the VNet link resource inside the Private DNS zone.')
param vnetLinkName string = 'vnetlink-sql'

// Azure SQL DNS suffix can be returned with a leading dot in some environments.
// Example: ".database.windows.net" -> we normalize it to "database.windows.net"
var sqlSuffixRaw = environment().suffixes.sqlServerHostname
var sqlSuffix = startsWith(sqlSuffixRaw, '.') ? substring(sqlSuffixRaw, 1) : sqlSuffixRaw

// Final zone name: privatelink.database.windows.net (or cloud-specific equivalent)
var privateDnsZoneName = 'privatelink.${sqlSuffix}'

// Private DNS Zone for Azure SQL Private Link
resource sqlPrivateDnsZone 'Microsoft.Network/privateDnsZones@2020-06-01' = {
  name: privateDnsZoneName
  location: 'global'
}

// Link the Private DNS zone to the VNet
resource sqlDnsVnetLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
  name: vnetLinkName
  parent: sqlPrivateDnsZone
  location: 'global'
  properties: {
    virtualNetwork: {
      id: vnetId
    }
    registrationEnabled: false
  }
}

output sqlPrivateDnsZoneId string = sqlPrivateDnsZone.id
output sqlPrivateDnsZoneName string = sqlPrivateDnsZone.name
output sqlSuffixRawOut string = sqlSuffixRaw
output sqlSuffixOut string = sqlSuffix




