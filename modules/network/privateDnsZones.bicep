targetScope = 'resourceGroup'

@description('VNet resource ID to link DNS zones to')
param vnetId string

@description('Create Key Vault private DNS zone')
param enableKeyVault bool = true

@description('Create Storage Blob private DNS zone')
param enableStorageBlob bool = true

@description('Create SQL private DNS zone')
param enableSql bool = true

// Suppress linter for well-known Azure DNS zone names
#disable-next-line no-hardcoded-env-urls
var kvZoneName = 'privatelink.vaultcore.azure.net'

#disable-next-line no-hardcoded-env-urls
var blobZoneName = 'privatelink.blob.core.windows.net'

#disable-next-line no-hardcoded-env-urls
var sqlZoneName = 'privatelink.database.windows.net'

// --- Key Vault zone + link
resource kvZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (enableKeyVault) {
  name: kvZoneName
  location: 'global'
}

resource kvLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (enableKeyVault) {
  parent: kvZone
  name: 'link-${uniqueString(vnetId, kvZoneName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// --- Storage Blob zone + link
resource blobZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (enableStorageBlob) {
  name: blobZoneName
  location: 'global'
}

resource blobLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (enableStorageBlob) {
  parent: blobZone
  name: 'link-${uniqueString(vnetId, blobZoneName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

// --- SQL zone + link
resource sqlZone 'Microsoft.Network/privateDnsZones@2020-06-01' = if (enableSql) {
  name: sqlZoneName
  location: 'global'
}

resource sqlLink 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = if (enableSql) {
  parent: sqlZone
  name: 'link-${uniqueString(vnetId, sqlZoneName)}'
  location: 'global'
  properties: {
    registrationEnabled: false
    virtualNetwork: {
      id: vnetId
    }
  }
}

output keyVaultPrivateDnsZoneId string = enableKeyVault ? kvZone.id : ''
output storageBlobPrivateDnsZoneId string = enableStorageBlob ? blobZone.id : ''
output sqlPrivateDnsZoneId string = enableSql ? sqlZone.id : ''
