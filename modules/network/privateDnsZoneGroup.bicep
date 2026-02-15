targetScope = 'resourceGroup'

@description('Private Endpoint resource ID')
param privateEndpointId string

@description('Private DNS Zone resource ID')
param privateDnsZoneId string

@description('Zone group name (keep default unless you have a reason)')
param zoneGroupName string = 'default'

resource pe 'Microsoft.Network/privateEndpoints@2023-09-01' existing = {
  scope: resourceGroup()
  name: last(split(privateEndpointId, '/'))
}

resource zoneGroup 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups@2023-09-01' = {
  parent: pe
  name: zoneGroupName
  properties: {
    privateDnsZoneConfigs: [
      {
        name: 'cfg'
        properties: {
          privateDnsZoneId: privateDnsZoneId
        }
      }
    ]
  }
}

output zoneGroupId string = zoneGroup.id
