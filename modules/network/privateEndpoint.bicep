targetScope = 'resourceGroup'

@description('Name of the Private Endpoint')
param privateEndpointName string

@description('Location of the Private Endpoint')
param location string = resourceGroup().location

@description('Subnet resource ID where the Private Endpoint will be deployed')
param subnetId string

@description('The resource ID of the target service (e.g. Key Vault, SQL, Storage)')
param privateLinkServiceId string

@description('The subresource/group for the Private Link service (e.g. vault, sqlServer, blob)')
param groupId string

@description('Connection name inside Private Endpoint')
param connectionName string = 'plc'

@description('Optional request message')
param requestMessage string = 'Private Endpoint connection request'

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-09-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnetId
    }
    privateLinkServiceConnections: [
      {
        name: connectionName
        properties: {
          privateLinkServiceId: privateLinkServiceId
          groupIds: [
            groupId
          ]
          requestMessage: requestMessage
        }
      }
    ]
  }
}

output privateEndpointId string = privateEndpoint.id
output privateEndpointNicId string = privateEndpoint.properties.networkInterfaces[0].id
