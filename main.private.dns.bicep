targetScope = 'resourceGroup'

@description('Resource ID of the Virtual Network to link Private DNS zones to.')
param vnetId string

@description('Resource ID of the Key Vault Private Endpoint.')
param kvPrivateEndpointId string

@description('Resource ID of the SQL Server Private Endpoint.')
param sqlPrivateEndpointId string

@description('Name of the VNet link resource for Key Vault Private DNS zone.')
param kvVnetLinkName string = 'vnetlink-kv'

@description('Name of the VNet link resource for SQL Private DNS zone.')
param sqlVnetLinkName string = 'vnetlink-sql'

// ============================================================================
// 1) Key Vault: Private DNS zone + VNet link
// ============================================================================
module kvDns './modules/network/privateDnsKv.bicep' = {
  name: 'kv-private-dns'
  params: {
    vnetId: vnetId
    vnetLinkName: kvVnetLinkName
  }
}

// Attach DNS Zone Group to the Key Vault Private Endpoint
module kvZoneGroup './modules/network/privateDnsZoneGroup.bicep' = {
  name: 'kv-private-dns-zone-group'
  params: {
    privateEndpointId: kvPrivateEndpointId
    privateDnsZoneId: kvDns.outputs.kvPrivateDnsZoneId
    zoneGroupName: 'default'
  }
}

// ============================================================================
// 2) SQL: Private DNS zone + VNet link
// ============================================================================
module sqlDns './modules/network/privateDnsSql.bicep' = {
  name: 'sql-private-dns'
  params: {
    vnetId: vnetId
    vnetLinkName: sqlVnetLinkName
  }
}

// Attach DNS Zone Group to the SQL Private Endpoint
module sqlZoneGroup './modules/network/privateDnsZoneGroup.bicep' = {
  name: 'sql-private-dns-zone-group'
  params: {
    privateEndpointId: sqlPrivateEndpointId
    privateDnsZoneId: sqlDns.outputs.sqlPrivateDnsZoneId
    zoneGroupName: 'default'
  }
}

// ============================================================================
// Outputs
// ============================================================================
output kvPrivateDnsZoneId string = kvDns.outputs.kvPrivateDnsZoneId
output sqlPrivateDnsZoneId string = sqlDns.outputs.sqlPrivateDnsZoneId
